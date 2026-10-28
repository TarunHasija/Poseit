"""Create the pose metadata table and storage bucket.

Revision ID: 0001_pose_schema
Revises:
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0001_pose_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "pose_images",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("bucket_name", sa.String(length=120), nullable=False),
        sa.Column("object_path", sa.String(length=500), nullable=False),
        sa.Column("original_filename", sa.String(length=255), nullable=False),
        sa.Column("mime_type", sa.String(length=100), nullable=False),
        sa.Column("size_bytes", sa.Integer(), nullable=False),
        sa.Column("original_size_bytes", sa.Integer(), nullable=False),
        sa.Column("width", sa.Integer(), nullable=False),
        sa.Column("height", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint(
            "mime_type IN ('image/jpeg', 'image/png', 'image/webp', 'image/gif')",
            name="ck_pose_images_mime_type",
        ),
        sa.CheckConstraint("size_bytes >= 0", name="ck_pose_images_size_bytes"),
        sa.CheckConstraint("original_size_bytes >= 0", name="ck_pose_images_original_size_bytes"),
        sa.CheckConstraint("width > 0", name="ck_pose_images_width"),
        sa.CheckConstraint("height > 0", name="ck_pose_images_height"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("object_path"),
    )
    op.create_index("ix_pose_images_created_at", "pose_images", ["created_at"], unique=False)
    op.execute(
        """
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('poses', 'poses', FALSE, 15728640,
                ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
        ON CONFLICT (id) DO UPDATE SET
            public = EXCLUDED.public,
            file_size_limit = EXCLUDED.file_size_limit,
            allowed_mime_types = EXCLUDED.allowed_mime_types
        """
    )


def downgrade() -> None:
    op.drop_index("ix_pose_images_created_at", table_name="pose_images")
    op.drop_table("pose_images")
    # Keep the Storage bucket on downgrade to avoid deleting uploaded objects.
