import base64
import json
import logging
from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import Response
from pydantic import TypeAdapter, ValidationError
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.concurrency import run_in_threadpool

from app.core.database import get_db
from app.core.security import get_current_user
from app.schemas.pose_img import BulkPoseMetadata, PoseMetadata, PoseMetadataUpdate, PoseWithImage
from app.services.pose_service import edit_pose_metadata, fetch_all_poses, fetch_pose, upload_pose, upload_poses_bulk

router = APIRouter(prefix="/poses", tags=["Poses"])
logger = logging.getLogger(__name__)


def _metadata(pose) -> dict:
    return PoseMetadata.model_validate(pose).model_dump(mode="json")


@router.post("", response_model=PoseMetadata, status_code=status.HTTP_201_CREATED)
async def create_pose_endpoint(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    _user: dict = Depends(get_current_user),
):
    try:
        pose, _ = await upload_pose(db, file)
        return pose
    except HTTPException:
        raise
    except Exception as exc:
        await db.rollback()
        raise HTTPException(status_code=502, detail="Pose upload failed") from exc
    finally:
        await file.close()


@router.post("/bulk", response_model=list[PoseMetadata], status_code=status.HTTP_201_CREATED)
async def create_poses_bulk_endpoint(
    files: list[UploadFile] = File(...),
    metadata_json: str | None = Form(None, alias="metadata", description="JSON metadata shared by every uploaded image"),
    poses: str | None = Form(None, description="JSON array of per-image metadata, aligned with files"),
    people_count: int | None = Form(None, ge=0),
    category: str | None = Form(None, min_length=1, max_length=120),
    created_at: datetime | None = Form(None),
    db: AsyncSession = Depends(get_db),
    _user: dict = Depends(get_current_user),
):
    try:
        supplied_modes = sum(value is not None for value in (metadata_json, poses))
        has_legacy_fields = any(value is not None for value in (people_count, category, created_at))
        if supplied_modes > 1 or (supplied_modes and has_legacy_fields):
            raise HTTPException(status_code=422, detail="Use either metadata, poses, or the legacy shared fields")

        if metadata_json is not None:
            try:
                shared_metadata = TypeAdapter(BulkPoseMetadata).validate_python(json.loads(metadata_json))
            except (json.JSONDecodeError, ValidationError) as exc:
                raise HTTPException(
                    status_code=422,
                    detail="metadata must be a JSON object with categories, counts, and created_at",
                ) from exc
            metadata = [shared_metadata.model_dump() for _ in files]
        elif poses is not None:
            try:
                parsed_poses = TypeAdapter(list[BulkPoseMetadata]).validate_python(json.loads(poses))
            except (json.JSONDecodeError, ValidationError) as exc:
                raise HTTPException(
                    status_code=422,
                    detail="poses must be a JSON array with categories, counts, and created_at for each image",
                ) from exc
            if len(parsed_poses) != len(files):
                raise HTTPException(status_code=422, detail="The poses array length must match the number of files")
            metadata = [item.model_dump() for item in parsed_poses]
        else:
            if any(value is None for value in (people_count, category, created_at)):
                raise HTTPException(
                    status_code=422,
                    detail="Provide metadata/poses JSON or all shared fields: people_count, category, created_at",
                )
            normalized_category = category.strip()
            if not normalized_category:
                raise HTTPException(status_code=422, detail="Category cannot be blank")
            shared = {
                "categories": [normalized_category],
                "people_count": people_count,
                "created_at": created_at,
            }
            metadata = [shared.copy() for _ in files]
        return await upload_poses_bulk(
            db,
            files,
            metadata=metadata,
        )
    except HTTPException:
        raise
    except Exception as exc:
        await db.rollback()
        logger.exception("Bulk pose upload failed")
        raise HTTPException(status_code=502, detail="Bulk pose upload failed") from exc
    finally:
        for file in files:
            await file.close()


@router.get("", response_model=list[PoseWithImage])
async def get_all_poses(
    db: AsyncSession = Depends(get_db),
    _user: dict = Depends(get_current_user),
):
    try:
        poses = await fetch_all_poses(db)
        return [
            {**_metadata(pose), "image_base64": base64.b64encode(image).decode("ascii")}
            for pose, image in poses
        ]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Unable to fetch poses from storage") from exc


@router.get("/{pose_id}")
async def get_pose_by_id(
    pose_id: UUID,
    db: AsyncSession = Depends(get_db),
    _user: dict = Depends(get_current_user),
):
    try:
        result = await fetch_pose(db, pose_id)
        if result is None:
            raise HTTPException(status_code=404, detail="Pose not found")
        pose, image = result
        filename = pose.object_path.rsplit("/", 1)[-1]
        return Response(
            content=image,
            media_type=pose.mime_type,
            headers={
                "Content-Disposition": f'inline; filename="{filename}"',
                "X-Pose-Id": str(pose.id),
                "X-Pose-Bucket": pose.bucket_name,
                "X-Pose-Object-Path": pose.object_path,
                "X-Pose-Size": str(len(image)),
                "X-Pose-Original-Size": str(pose.original_size_bytes),
                "X-Pose-Width": str(pose.width),
                "X-Pose-Height": str(pose.height),
                "X-Pose-Created-At": pose.created_at.isoformat(),
            },
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Unable to fetch pose from storage") from exc


@router.patch("/{pose_id}", response_model=PoseMetadata)
async def update_pose_endpoint(
    pose_id: UUID,
    changes: PoseMetadataUpdate,
    db: AsyncSession = Depends(get_db),
    _user: dict = Depends(get_current_user),
):
    update_values = changes.model_dump(exclude_unset=True)
    if not update_values:
        raise HTTPException(status_code=422, detail="Provide at least one metadata field to update")
    if any(value is None for value in update_values.values()):
        raise HTTPException(status_code=422, detail="Metadata fields cannot be null")

    try:
        pose = await edit_pose_metadata(db, pose_id, update_values)
        if pose is None:
            raise HTTPException(status_code=404, detail="Pose not found")
        return pose
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail="Unable to update pose metadata") from exc
