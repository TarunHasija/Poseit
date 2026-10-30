"""Add normalized multiple categories per pose.

Revision ID: 0003_pose_categories
Revises: 0002_bulk_pose_metadata
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0003_pose_categories"
down_revision = "0002_bulk_pose_metadata"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "categories",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name"),
    )
    op.create_table(
        "pose_categories",
        sa.Column("pose_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("category_id", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["category_id"], ["categories.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["pose_id"], ["pose_images.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("pose_id", "category_id"),
    )
    op.create_index("ix_pose_categories_category_id", "pose_categories", ["category_id"], unique=False)
    op.execute(
        """
        INSERT INTO categories (name)
        SELECT DISTINCT lower(trim(category))
        FROM pose_images
        WHERE trim(category) <> ''
        ON CONFLICT (name) DO NOTHING
        """
    )
    op.execute(
        """
        INSERT INTO pose_categories (pose_id, category_id)
        SELECT p.id, c.id
        FROM pose_images AS p
        JOIN categories AS c ON c.name = lower(trim(p.category))
        ON CONFLICT (pose_id, category_id) DO NOTHING
        """
    )


def downgrade() -> None:
    op.drop_index("ix_pose_categories_category_id", table_name="pose_categories")
    op.drop_table("pose_categories")
    op.drop_table("categories")
