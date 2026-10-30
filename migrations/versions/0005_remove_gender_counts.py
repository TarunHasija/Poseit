"""Remove male and female counts from pose metadata.

Revision ID: 0005_remove_gender_counts
Revises: 0004_remove_legacy_category
"""

from alembic import op
import sqlalchemy as sa

revision = "0005_remove_gender_counts"
down_revision = "0004_remove_legacy_category"
branch_labels = None
depends_on = None


def upgrade() -> None:
    bind = op.get_bind()
    constraints = {
        constraint["name"]
        for constraint in sa.inspect(bind).get_check_constraints("pose_images")
    }
    for name in ("ck_pose_images_male", "ck_pose_images_female"):
        if name in constraints:
            op.drop_constraint(name, "pose_images", type_="check")

    columns = {column["name"] for column in sa.inspect(bind).get_columns("pose_images")}
    for name in ("male", "female"):
        if name in columns:
            op.drop_column("pose_images", name)


def downgrade() -> None:
    columns = {column["name"] for column in sa.inspect(op.get_bind()).get_columns("pose_images")}
    if "male" not in columns:
        op.add_column("pose_images", sa.Column("male", sa.Integer(), server_default="0", nullable=False))
    if "female" not in columns:
        op.add_column("pose_images", sa.Column("female", sa.Integer(), server_default="0", nullable=False))
    op.create_check_constraint("ck_pose_images_male", "pose_images", "male >= 0")
    op.create_check_constraint("ck_pose_images_female", "pose_images", "female >= 0")
