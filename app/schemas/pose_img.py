from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


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
    category: str = "Uncategorized"
    male: int = 0
    female: int = 0
    created_at: datetime


class PoseWithImage(PoseMetadata):
    image_base64: str
