from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional


class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    phone: Optional[str] = None
    email_confirmed_at: datetime | None = None
    phone_confirmed_at: datetime | None = None

class SignupResponse(BaseModel):
    message: str
    user: UserResponse

class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

class LoginResponse(BaseModel):
    message: str
    access_token: str
    refresh_token: str
    expires_at: Optional[int] = None
    user: UserResponse