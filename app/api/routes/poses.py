import base64
from uuid import UUID

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import Response
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.concurrency import run_in_threadpool

from app.core.database import get_db
from app.core.security import get_current_user
from app.schemas.pose_img import PoseMetadata, PoseWithImage
from app.services.pose_service import fetch_all_poses, fetch_pose, upload_pose

router = APIRouter(prefix="/poses", tags=["Poses"])


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
