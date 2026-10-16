from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import DateTime, Integer, String, func, select
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class PoseImage(Base):
    __tablename__ = "pose_images"

    id: Mapped[UUID] = mapped_column(PostgreSQLUUID(as_uuid=True), primary_key=True, default=uuid4)
    bucket_name: Mapped[str] = mapped_column(String(120), nullable=False)
    object_path: Mapped[str] = mapped_column(String(500), nullable=False, unique=True)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)
    original_size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)
    width: Mapped[int] = mapped_column(Integer, nullable=False)
    height: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())


async def create_pose(db: AsyncSession, **values) -> PoseImage:
    pose = PoseImage(**values)
    db.add(pose)
    await db.flush()
    await db.refresh(pose)
    return pose


async def get_pose(db: AsyncSession, pose_id: UUID) -> PoseImage | None:
    return await db.get(PoseImage, pose_id)


async def list_poses(db: AsyncSession) -> list[PoseImage]:
    result = await db.execute(select(PoseImage).order_by(PoseImage.created_at.desc()))
    return list(result.scalars().all())
