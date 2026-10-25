from __future__ import annotations

from io import BytesIO
from datetime import datetime, timezone
from pathlib import Path
from uuid import UUID, uuid4

from fastapi import HTTPException, UploadFile, status
from PIL import Image, UnidentifiedImageError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.supabase import supabase
from app.repositories.db.pose_repo import PoseImage, create_pose, get_pose, list_poses

ALLOWED_FORMATS = {
    "JPEG": ("image/jpeg", "jpg"),
    "PNG": ("image/png", "png"),
    "WEBP": ("image/webp", "webp"),
    "GIF": ("image/gif", "gif"),
}
MAX_IMAGE_BYTES = 15 * 1024 * 1024
MAX_BULK_IMAGE_COUNT = 20
MAX_BULK_TOTAL_BYTES = 100 * 1024 * 1024


def _optimize_image(data: bytes, declared_mime: str) -> tuple[bytes, str, int, int]:
    try:
        with Image.open(BytesIO(data)) as image:
            image_format = image.format
            image.load()  # Decode the upload and reject malformed image data.
            width, height = image.size
            if image_format not in ALLOWED_FORMATS:
                raise HTTPException(status_code=415, detail="Only JPEG, PNG, WEBP, and GIF images are supported")
            mime_type, _ = ALLOWED_FORMATS[image_format]
            if declared_mime.lower() != mime_type:
                raise HTTPException(status_code=415, detail="The file content does not match its image MIME type")

            output = BytesIO()
            if image_format == "JPEG":
                if image.mode not in ("RGB", "L"):
                    image = image.convert("RGB")
                image.save(output, format="JPEG", optimize=True, quality=85, progressive=True)
            elif image_format == "PNG":
                image.save(output, format="PNG", optimize=True)
            elif image_format == "WEBP":
                image.save(output, format="WEBP", method=6, quality=85)
            else:
                image.save(output, format="GIF", optimize=True)
            return output.getvalue(), mime_type, width, height
    except UnidentifiedImageError as exc:
        raise HTTPException(status_code=415, detail="Upload must contain a valid image") from exc


def _decode_for_response(data: bytes, expected_mime: str) -> bytes:
    """Decode stored pixels and re-encode them for transfer, rejecting corrupt objects."""
    optimized, mime_type, _, _ = _optimize_image(data, expected_mime)
    return optimized


def _upload_object(path: str, data: bytes, mime_type: str) -> None:
    supabase.storage.from_(settings.SUPABASE_POSES_BUCKET).upload(
        path,
        data,
        {"content-type": mime_type, "upsert": "false"},
    )


def _download_object(bucket: str, path: str) -> bytes:
    return supabase.storage.from_(bucket).download(path)


def _remove_object(bucket: str, path: str) -> None:
    supabase.storage.from_(bucket).remove([path])


async def upload_pose(db: AsyncSession, file: UploadFile) -> tuple[PoseImage, bytes]:
    from starlette.concurrency import run_in_threadpool

    declared_mime = (file.content_type or "").split(";", 1)[0].strip().lower()
    if not declared_mime.startswith("image/"):
        raise HTTPException(status_code=415, detail="Only image MIME types are allowed")
    raw = await file.read(MAX_IMAGE_BYTES + 1)
    if not raw:
        raise HTTPException(status_code=400, detail="Image file is empty")
    if len(raw) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image exceeds the 15 MiB upload limit")
    optimized, mime_type, width, height = _optimize_image(raw, declared_mime)

    pose_id = uuid4()
    extension = ALLOWED_FORMATS[Image.open(BytesIO(optimized)).format][1]
    object_path = f"{pose_id}.{extension}"
    await run_in_threadpool(_upload_object, object_path, optimized, mime_type)
    try:
        pose = await create_pose(
            db,
            id=pose_id,
            bucket_name=settings.SUPABASE_POSES_BUCKET,
            object_path=object_path,
            original_filename=Path(file.filename or "pose").name[:255],
            mime_type=mime_type,
            size_bytes=len(optimized),
            original_size_bytes=len(raw),
            width=width,
            height=height,
        )
        await db.commit()
    except Exception:
        await db.rollback()
        await run_in_threadpool(_remove_object, settings.SUPABASE_POSES_BUCKET, object_path)
        raise
    return pose, optimized


async def upload_poses_bulk(
    db: AsyncSession,
    files: list[UploadFile],
    *,
    people_count: int,
    category: str,
    male: int,
    female: int,
    created_at: datetime,
) -> list[PoseImage]:
    """Store images with one shared set of metadata and a unique UUID per image."""
    from starlette.concurrency import run_in_threadpool

    if not files:
        raise HTTPException(status_code=400, detail="At least one image is required")
    if len(files) > MAX_BULK_IMAGE_COUNT:
        raise HTTPException(status_code=413, detail=f"Bulk upload is limited to {MAX_BULK_IMAGE_COUNT} images")

    normalized_created_at = (
        created_at.replace(tzinfo=timezone.utc)
        if created_at.tzinfo is None
        else created_at
    )
    uploaded_objects: list[tuple[str, str]] = []
    total_bytes = 0
    poses: list[PoseImage] = []
    try:
        for file in files:
            declared_mime = (file.content_type or "").split(";", 1)[0].strip().lower()
            if not declared_mime.startswith("image/"):
                raise HTTPException(status_code=415, detail="Only image MIME types are allowed")
            raw = await file.read(MAX_IMAGE_BYTES + 1)
            if not raw:
                raise HTTPException(status_code=400, detail="Image file is empty")
            if len(raw) > MAX_IMAGE_BYTES:
                raise HTTPException(status_code=413, detail="An image exceeds the 15 MiB upload limit")
            total_bytes += len(raw)
            if total_bytes > MAX_BULK_TOTAL_BYTES:
                raise HTTPException(status_code=413, detail="Bulk upload exceeds the 100 MiB total limit")

            optimized, mime_type, width, height = _optimize_image(raw, declared_mime)
            pose_id = uuid4()
            extension = ALLOWED_FORMATS[Image.open(BytesIO(optimized)).format][1]
            object_path = f"{pose_id}.{extension}"
            bucket = settings.SUPABASE_POSES_BUCKET
            uploaded_objects.append((bucket, object_path))
            await run_in_threadpool(_upload_object, object_path, optimized, mime_type)
            poses.append(
                await create_pose(
                    db,
                    id=pose_id,
                    bucket_name=bucket,
                    object_path=object_path,
                    original_filename=Path(file.filename or "pose").name[:255],
                    mime_type=mime_type,
                    size_bytes=len(optimized),
                    original_size_bytes=len(raw),
                    width=width,
                    height=height,
                    people_count=people_count,
                    category=category,
                    male=male,
                    female=female,
                    created_at=normalized_created_at,
                )
            )

        await db.commit()
        return poses
    except Exception:
        await db.rollback()
        for bucket, object_path in reversed(uploaded_objects):
            try:
                await run_in_threadpool(_remove_object, bucket, object_path)
            except Exception:
                # Keep the original error if cleanup itself fails.
                pass
        raise


async def fetch_pose(db: AsyncSession, pose_id: UUID) -> tuple[PoseImage, bytes] | None:
    from starlette.concurrency import run_in_threadpool

    pose = await get_pose(db, pose_id)
    if pose is None:
        return None
    stored = await run_in_threadpool(_download_object, pose.bucket_name, pose.object_path)
    return pose, _decode_for_response(stored, pose.mime_type)


async def fetch_all_poses(db: AsyncSession) -> list[tuple[PoseImage, bytes]]:
    from starlette.concurrency import run_in_threadpool

    poses = await list_poses(db)
    results = []
    for pose in poses:
        stored = await run_in_threadpool(_download_object, pose.bucket_name, pose.object_path)
        results.append((pose, _decode_for_response(stored, pose.mime_type)))
    return results
