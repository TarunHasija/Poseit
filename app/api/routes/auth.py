from fastapi import APIRouter, HTTPException, Depends

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.supabase import supabase
from app.schemas import auth
from app.core.security import get_current_user
from app.core.database import get_db

from app.services.auth_service import AuthService


router = APIRouter(prefix="/auth", tags=["Auth"])

auth_service = AuthService()


@router.post("/signup")
async def signup(payload: auth.SignupRequest):

    try:
        response = await auth_service.signup_user(
                email = payload.email,
                password = payload.password
        )

        return response

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/login", response_model = auth.LoginResponse, status_code = 200)
async def login(payload: auth.LoginRequest):
    try:
        return await auth_service.login_user(
            email=payload.email,
            password=payload.password
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


# 