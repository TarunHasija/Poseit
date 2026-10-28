"""Add bulk pose metadata fields.

Revision ID: 0002_bulk_pose_metadata
Revises: 0001_pose_schema
"""

from alembic import op
import sqlalchemy as sa

revision = "0002_bulk_pose_metadata"
down_revision = "0001_pose_schema"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pose_images", sa.Column("people_count", sa.Integer(), server_default="1", nullable=False))
    op.add_column(
        "pose_images",
        sa.Column("category", sa.String(length=120), server_default=sa.text("'Uncategorized'"), nullable=False),
    )
    op.add_column("pose_images", sa.Column("male", sa.Integer(), server_default="0", nullable=False))
    op.add_column("pose_images", sa.Column("female", sa.Integer(), server_default="0", nullable=False))
    op.create_check_constraint("ck_pose_images_people_count", "pose_images", "people_count >= 0")
    op.create_check_constraint("ck_pose_images_male", "pose_images", "male >= 0")
    op.create_check_constraint("ck_pose_images_female", "pose_images", "female >= 0")


def downgrade() -> None:
    op.drop_constraint("ck_pose_images_female", "pose_images", type_="check")
    op.drop_constraint("ck_pose_images_male", "pose_images", type_="check")
    op.drop_constraint("ck_pose_images_people_count", "pose_images", type_="check")
    op.drop_column("pose_images", "female")
    op.drop_column("pose_images", "male")
    op.drop_column("pose_images", "category")
    op.drop_column("pose_images", "people_count")