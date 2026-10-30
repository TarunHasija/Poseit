"""Remove the legacy single-category column from pose_images.

Revision ID: 0004_remove_legacy_category
Revises: 0003_pose_categories
"""

from alembic import op
import sqlalchemy as sa

revision = "0004_remove_legacy_category"
down_revision = "0003_pose_categories"
branch_labels = None
depends_on = None


def upgrade() -> None:
    columns = {column["name"] for column in sa.inspect(op.get_bind()).get_columns("pose_images")}
    # Allow this migration to run on databases where the column was removed manually.
    if "category" in columns:
        op.drop_column("pose_images", "category")


def downgrade() -> None:
    columns = {column["name"] for column in sa.inspect(op.get_bind()).get_columns("pose_images")}
    if "category" not in columns:
        op.add_column("pose_images", sa.Column("category", sa.String(length=120), nullable=True))
    op.execute(
        """
        UPDATE pose_images AS p
        SET category = COALESCE(
            (SELECT c.name
             FROM pose_categories AS pc
             JOIN categories AS c ON c.id = pc.category_id
             WHERE pc.pose_id = p.id
             ORDER BY c.name
             LIMIT 1),
            'Uncategorized'
        )
        """
    )
    op.alter_column("pose_images", "category", nullable=False, server_default="Uncategorized")
