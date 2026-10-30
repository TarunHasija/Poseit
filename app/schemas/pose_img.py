from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class PoseMetadata(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    bucket_name: str
    object_path: str
    original_filename: str
    mime_type: str
    size_bytes: int
    original_size_bytes: int
    width: int
    height: int
    people_count: int = 1
    category: str = Field(default="Uncategorized", validation_alias="primary_category")
    categories: list[str] = Field(default_factory=list, validation_alias="category_names")
    created_at: datetime


class PoseWithImage(PoseMetadata):
    image_base64: str


class PoseMetadataUpdate(BaseModel):
    """Fields that can be edited without replacing the stored image."""

    people_count: int | None = Field(default=None, ge=0)
    category: str | None = Field(default=None, min_length=1, max_length=120)
    categories: list[str] | None = Field(default=None, max_length=20)
    created_at: datetime | None = None


class BulkPoseMetadata(BaseModel):
    categories: list[str] = Field(min_length=1, max_length=20)
    people_count: int = Field(ge=0)
    created_at: datetime

    @field_validator("categories")
    @classmethod
    def validate_categories(cls, categories: list[str]) -> list[str]:
        cleaned = [category.strip() for category in categories]
        if any(not category for category in cleaned):
            raise ValueError("Category names cannot be blank")
        if any(len(category) > 120 for category in cleaned):
            raise ValueError("Category names cannot exceed 120 characters")
        return list(dict.fromkeys(cleaned))
