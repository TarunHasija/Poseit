from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import CheckConstraint, Column, DateTime, ForeignKey, Index, Integer, String, Table, func, select
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column, relationship, selectinload

from app.core.db_base import Base


pose_categories = Table(
    "pose_categories",
    Base.metadata,
    Column("pose_id", PostgreSQLUUID(as_uuid=True), ForeignKey("pose_images.id", ondelete="CASCADE"), primary_key=True),
    Column("category_id", Integer, ForeignKey("categories.id", ondelete="CASCADE"), primary_key=True),
)
Index("ix_pose_categories_category_id", pose_categories.c.category_id)


class Category(Base):
    __tablename__ = "categories"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False, unique=True)


class PoseImage(Base):
    __tablename__ = "pose_images"
    __table_args__ = (
        CheckConstraint(
            "mime_type IN ('image/jpeg', 'image/png', 'image/webp', 'image/gif')",
            name="ck_pose_images_mime_type",
        ),
        CheckConstraint("size_bytes >= 0", name="ck_pose_images_size_bytes"),
        CheckConstraint("original_size_bytes >= 0", name="ck_pose_images_original_size_bytes"),
        CheckConstraint("width > 0", name="ck_pose_images_width"),
        CheckConstraint("height > 0", name="ck_pose_images_height"),
        CheckConstraint("people_count >= 0", name="ck_pose_images_people_count"),
    )

    id: Mapped[UUID] = mapped_column(PostgreSQLUUID(as_uuid=True), primary_key=True, default=uuid4)
    bucket_name: Mapped[str] = mapped_column(String(120), nullable=False)
    object_path: Mapped[str] = mapped_column(String(500), nullable=False, unique=True)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)
    original_size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)
    width: Mapped[int] = mapped_column(Integer, nullable=False)
    height: Mapped[int] = mapped_column(Integer, nullable=False)
    people_count: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())
    linked_categories: Mapped[list[Category]] = relationship(secondary=pose_categories, lazy="selectin")

    @property
    def category_names(self) -> list[str]:
        return [category.name for category in self.linked_categories]

    @property
    def primary_category(self) -> str:
        return self.category_names[0] if self.category_names else "Uncategorized"


async def create_pose(db: AsyncSession, **values) -> PoseImage:
    category_names = values.pop("categories", ["Uncategorized"])
    pose = PoseImage(**values)
    # Initialize the collection before flushing. Assigning to an uninitialized
    # relationship after the row becomes persistent triggers an implicit lazy
    # load, which is not allowed inside async SQLAlchemy.
    pose.linked_categories = []
    db.add(pose)
    await db.flush()
    normalized = list(dict.fromkeys(name.strip().lower() for name in category_names))
    result = await db.execute(select(Category).where(Category.name.in_(normalized)))
    categories_by_name = {item.name: item for item in result.scalars().all()}
    for name in normalized:
        if name not in categories_by_name:
            category = Category(name=name)
            db.add(category)
            await db.flush()
            categories_by_name[name] = category
    pose.linked_categories = [categories_by_name[name] for name in normalized]
    await db.flush()
    # Refresh the server-generated timestamp without expiring the eagerly
    # assigned category relationship; async lazy loading cannot happen here.
    await db.refresh(pose, attribute_names=["created_at"])
    return pose


async def get_pose(db: AsyncSession, pose_id: UUID) -> PoseImage | None:
    result = await db.execute(
        select(PoseImage).options(selectinload(PoseImage.linked_categories)).where(PoseImage.id == pose_id)
    )
    return result.scalar_one_or_none()


async def update_pose(db: AsyncSession, pose: PoseImage, **values) -> PoseImage:
    category_names = values.pop("categories", None)
    if category_names is not None:
        normalized = list(dict.fromkeys(name.strip().lower() for name in category_names))
        query = await db.execute(select(Category).where(Category.name.in_(normalized)))
        categories_by_name = {item.name: item for item in query.scalars().all()}
        for name in normalized:
            if name not in categories_by_name:
                category = Category(name=name)
                db.add(category)
                await db.flush()
                categories_by_name[name] = category
        pose.linked_categories = [categories_by_name[name] for name in normalized]
    for field, value in values.items():
        setattr(pose, field, value)
    await db.flush()
    return pose


async def list_poses(db: AsyncSession) -> list[PoseImage]:
    result = await db.execute(
        select(PoseImage).options(selectinload(PoseImage.linked_categories)).order_by(PoseImage.created_at.desc())
    )
    return list(result.scalars().all())
