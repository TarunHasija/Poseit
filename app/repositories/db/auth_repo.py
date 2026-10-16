from app.core.supabase import supabase_auth

class AuthRepository:
    async def signup(self, email: str, password: str):
        try:
            return supabase_auth.auth.sign_up(
                {
                    "email": email,
                    "password": password,
                }
            )
        
        except Exception as e:
            print("SIGNUP REPO LAYER ERROR:", repr(e))
            raise

    async def login(self, email: str, password: str):
        try:
            return supabase_auth.auth.sign_in_with_password(
                {
                    "email": email,
                    "password": password
                }
            )
        except Exception as e:
            print("LOGIN REPO LAYER ERROR:", repr(e))
            raise

auth_repo = AuthRepository()
