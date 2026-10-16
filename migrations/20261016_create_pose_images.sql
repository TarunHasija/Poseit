-- Metadata for images stored in the private Supabase Storage bucket named `poses`.
CREATE TABLE IF NOT EXISTS pose_images (
    id UUID PRIMARY KEY,
    bucket_name VARCHAR(120) NOT NULL,
    object_path VARCHAR(500) NOT NULL UNIQUE,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp', 'image/gif')),
    size_bytes INTEGER NOT NULL CHECK (size_bytes >= 0),
    original_size_bytes INTEGER NOT NULL CHECK (original_size_bytes >= 0),
    width INTEGER NOT NULL CHECK (width > 0),
    height INTEGER NOT NULL CHECK (height > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_pose_images_created_at ON pose_images (created_at DESC);

-- Create the storage bucket and restrict object MIME types to supported image formats.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('poses', 'poses', FALSE, 15728640, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;
