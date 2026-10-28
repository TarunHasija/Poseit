-- Add the shared demographic and category fields used by bulk uploads.
ALTER TABLE pose_images
    ADD COLUMN IF NOT EXISTS people_count INTEGER NOT NULL DEFAULT 1 CHECK (people_count >= 0),
    ADD COLUMN IF NOT EXISTS category VARCHAR(120) NOT NULL DEFAULT 'Uncategorized',
    ADD COLUMN IF NOT EXISTS male INTEGER NOT NULL DEFAULT 0 CHECK (male >= 0),
    ADD COLUMN IF NOT EXISTS female INTEGER NOT NULL DEFAULT 0 CHECK (female >= 0);
