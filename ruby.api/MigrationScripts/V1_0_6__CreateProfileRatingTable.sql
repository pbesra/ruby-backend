-- V1_0_6__CreateProfileRatingTable.sql
-- Aggregated profile rating to support O(1) average updates.

CREATE TABLE IF NOT EXISTS public.profileratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profileid uuid NOT NULL,
  currentrating double precision NOT NULL CHECK (currentrating >= 0 AND currentrating <= 5),
  meanrating double precision NOT NULL CHECK (meanrating >= 0 AND meanrating <= 5),
  leastrating double precision NOT NULL CHECK (leastrating >= 0 AND leastrating <= 5),
  ratingcount integer NOT NULL DEFAULT 1 CHECK (ratingcount > 0),
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_profileratings_profileid
  ON public.profileratings (profileid);

CREATE INDEX IF NOT EXISTS ix_profileratings_updatedby
  ON public.profileratings (updatedby);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profileratings_profile') THEN
    EXECUTE 'ALTER TABLE public.profileratings ADD CONSTRAINT fk_profileratings_profile FOREIGN KEY (profileid) REFERENCES public.profiles(userid) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profileratings_updatedby') THEN
    EXECUTE 'ALTER TABLE public.profileratings ADD CONSTRAINT fk_profileratings_updatedby FOREIGN KEY (updatedby) REFERENCES public.useraccount(id) ON DELETE SET NULL';
  END IF;
END;
$$;

DROP TRIGGER IF EXISTS trg_profileratings_update_timestamp ON public.profileratings;
CREATE TRIGGER trg_profileratings_update_timestamp
BEFORE UPDATE ON public.profileratings
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
