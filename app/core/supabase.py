from supabase import create_client
from app.core.config import settings

supabase = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_SERVICE_ROLE_KEY,
)

# Public authentication calls must use the anon key. Keep privileged storage
# operations on the service-role client above.
supabase_auth = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_ANON_KEY,
)
