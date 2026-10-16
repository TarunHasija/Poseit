import pydantic_settings

class Settings(pydantic_settings.BaseSettings):
    APP_NAME: str = "MEDWI"

    DATABASE_URL: str
    ALEMBIC_DATABASE_URL: str

    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str
    SUPABASE_JWT_SECRET: str
    SUPABASE_POSES_BUCKET: str = "poses"

    DEBUG: bool = True

    class Config:
        env_file = ".env"

settings = Settings()
