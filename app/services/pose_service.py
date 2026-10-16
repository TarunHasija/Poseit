from __future__ import annotations

from io import BytesIO
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
