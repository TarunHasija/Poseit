from app.repositories.db.auth_repo import auth_repo
from app.schemas.auth import (SignupResponse, LoginResponse, UserResponse)


class AuthService:

    async def signup_user(self, email: str, password: str) -> SignupResponse:
        try:
            print("SIGNUP SERVICE CALLED")
            response = await auth_repo.signup(
                email=email,
                password=password
            )
            return SignupResponse(
                    message="Login successful",
                    user=UserResponse(
                        id=response.user.id,
                        email=response.user.email,
                        email_confirmed_at=response.user.email_confirmed_at,
                        phone_confirmed_at=response.user.phone_confirmed_at
                    )
                )

        except Exception as e:
            print("SIGNUP SERVICE ERROR:", repr(e))
            raise


    async def login_user(self, email: str, password: str) -> LoginResponse:
        try:
            print("LOGIN SERVICE CALLED")
            response = await auth_repo.login(
                email=email,
                password=password
            )

            return LoginResponse(
                message="Login successful",
                access_token=response.session.access_token,
                refresh_token=response.session.refresh_token,
                expires_at=response.session.expires_at,
                user=UserResponse(
                    id=response.user.id,
                    email=response.user.email,
                    email_confirmed_at=response.user.email_confirmed_at,
                    phone_confirmed_at=response.user.phone_confirmed_at
                )
            )

        except Exception as e:
            print("LOGIN SERVICE ERROR:", repr(e))
            raise
