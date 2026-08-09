-- V1_0_8__CreateProfileRatingVotesTable.sql
-- Stores individual votes: who rated which profile and how much.

CREATE TABLE IF NOT EXISTS public.profileratingvotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profileid uuid NOT NULL,
  ratedbyuserid uuid NOT NULL,
  rating double precision NOT NULL CHECK (rating >= 0 AND rating <= 5),
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_profileratingvotes_not_self CHECK (profileid <> ratedbyuserid)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_profileratingvotes_profile_rater
  ON public.profileratingvotes (profileid, ratedbyuserid);

CREATE INDEX IF NOT EXISTS ix_profileratingvotes_profileid
  ON public.profileratingvotes (profileid);

CREATE INDEX IF NOT EXISTS ix_profileratingvotes_ratedbyuserid
  ON public.profileratingvotes (ratedbyuserid);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profileratingvotes_profile') THEN
    EXECUTE 'ALTER TABLE public.profileratingvotes ADD CONSTRAINT fk_profileratingvotes_profile FOREIGN KEY (profileid) REFERENCES public.profiles(userid) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profileratingvotes_ratedby') THEN
    EXECUTE 'ALTER TABLE public.profileratingvotes ADD CONSTRAINT fk_profileratingvotes_ratedby FOREIGN KEY (ratedbyuserid) REFERENCES public.users(id) ON DELETE CASCADE';
  END IF;
END;
$$;

DROP TRIGGER IF EXISTS trg_profileratingvotes_update_timestamp ON public.profileratingvotes;
CREATE TRIGGER trg_profileratingvotes_update_timestamp
BEFORE UPDATE ON public.profileratingvotes
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
