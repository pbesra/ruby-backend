-- V1_0_7__UpgradeProfileRatingColumns.sql
-- Upgrade legacy profileratings schema (rating only) to current/mean/least structure.

ALTER TABLE public.profileratings
  ADD COLUMN IF NOT EXISTS currentrating double precision,
  ADD COLUMN IF NOT EXISTS meanrating double precision,
  ADD COLUMN IF NOT EXISTS leastrating double precision;

-- Backfill from old rating column when available.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profileratings'
      AND column_name = 'rating'
  ) THEN
    EXECUTE '
      UPDATE public.profileratings
      SET
        currentrating = COALESCE(currentrating, rating),
        meanrating = COALESCE(meanrating, rating),
        leastrating = COALESCE(leastrating, rating)
      WHERE currentrating IS NULL OR meanrating IS NULL OR leastrating IS NULL';
  END IF;
END;
$$;

-- Safety defaults for any remaining nulls.
UPDATE public.profileratings
SET
  currentrating = COALESCE(currentrating, 0),
  meanrating = COALESCE(meanrating, 0),
  leastrating = COALESCE(leastrating, 0)
WHERE currentrating IS NULL OR meanrating IS NULL OR leastrating IS NULL;

ALTER TABLE public.profileratings
  ALTER COLUMN currentrating SET NOT NULL,
  ALTER COLUMN meanrating SET NOT NULL,
  ALTER COLUMN leastrating SET NOT NULL;

-- Ensure constraints exist on new columns.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_profileratings_currentrating') THEN
    EXECUTE 'ALTER TABLE public.profileratings ADD CONSTRAINT ck_profileratings_currentrating CHECK (currentrating >= 0 AND currentrating <= 5)';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_profileratings_meanrating') THEN
    EXECUTE 'ALTER TABLE public.profileratings ADD CONSTRAINT ck_profileratings_meanrating CHECK (meanrating >= 0 AND meanrating <= 5)';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_profileratings_leastrating') THEN
    EXECUTE 'ALTER TABLE public.profileratings ADD CONSTRAINT ck_profileratings_leastrating CHECK (leastrating >= 0 AND leastrating <= 5)';
  END IF;
END;
$$;

-- Drop old rating column if present.
ALTER TABLE public.profileratings
  DROP COLUMN IF EXISTS rating;
