-- V1_0_3__CreateFollowersFollowingTable.sql
-- Creates follower/following relationship table.

CREATE TABLE IF NOT EXISTS public.followers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  followeruserid uuid NOT NULL,
  followinguserid uuid NOT NULL,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid,
  CONSTRAINT ck_followers_not_self CHECK (followeruserid <> followinguserid)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_followers_pair
  ON public.followers (followeruserid, followinguserid);

CREATE INDEX IF NOT EXISTS ix_followers_followeruserid
  ON public.followers (followeruserid);

CREATE INDEX IF NOT EXISTS ix_followers_followinguserid
  ON public.followers (followinguserid);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followers_follower_user') THEN
    EXECUTE 'ALTER TABLE public.followers ADD CONSTRAINT fk_followers_follower_user FOREIGN KEY (followeruserid) REFERENCES public.useraccount(id) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followers_following_user') THEN
    EXECUTE 'ALTER TABLE public.followers ADD CONSTRAINT fk_followers_following_user FOREIGN KEY (followinguserid) REFERENCES public.useraccount(id) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followers_updatedby_user') THEN
    EXECUTE 'ALTER TABLE public.followers ADD CONSTRAINT fk_followers_updatedby_user FOREIGN KEY (updatedby) REFERENCES public.useraccount(id) ON DELETE SET NULL';
  END IF;
END;
$$;

DROP TRIGGER IF EXISTS trg_followers_update_timestamp ON public.followers;
CREATE TRIGGER trg_followers_update_timestamp
BEFORE UPDATE ON public.followers
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

CREATE TABLE IF NOT EXISTS public.followings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  followinguserid uuid NOT NULL,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid,
  CONSTRAINT ck_followings_not_self CHECK (userid <> followinguserid)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_followings_pair
  ON public.followings (userid, followinguserid);

CREATE INDEX IF NOT EXISTS ix_followings_userid
  ON public.followings (userid);

CREATE INDEX IF NOT EXISTS ix_followings_followinguserid
  ON public.followings (followinguserid);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followings_user') THEN
    EXECUTE 'ALTER TABLE public.followings ADD CONSTRAINT fk_followings_user FOREIGN KEY (userid) REFERENCES public.useraccount(id) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followings_following_user') THEN
    EXECUTE 'ALTER TABLE public.followings ADD CONSTRAINT fk_followings_following_user FOREIGN KEY (followinguserid) REFERENCES public.useraccount(id) ON DELETE CASCADE';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_followings_updatedby_user') THEN
    EXECUTE 'ALTER TABLE public.followings ADD CONSTRAINT fk_followings_updatedby_user FOREIGN KEY (updatedby) REFERENCES public.useraccount(id) ON DELETE SET NULL';
  END IF;
END;
$$;

DROP TRIGGER IF EXISTS trg_followings_update_timestamp ON public.followings;
CREATE TRIGGER trg_followings_update_timestamp
BEFORE UPDATE ON public.followings
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

-- Seed follower graph for quick-login device users.
-- This creates both:
-- 1) device user -> fake users (following)
-- 2) fake users -> device user (followers)
-- and remains safe to re-run.

WITH device_users AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) LIKE 'device:%'
),
seed_targets AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) IN (
    'alex.hayes01', 'jamie.reed02', 'taylor.quinn03',
    'morgan.ellis04', 'riley.carter05', 'casey.blake06',
    'drew.turner07', 'mika.brooks08', 'parker.rowan09',
    'jordan.flynn10'
  )
)
INSERT INTO public.followers (followeruserid, followinguserid, createdat, updatedat)
SELECT
  du.id,
  st.id,
  now(),
  now()
FROM device_users du
JOIN LATERAL (
  SELECT id
  FROM seed_targets st
  WHERE st.id <> du.id
  ORDER BY id
  LIMIT 4
) st ON true
ON CONFLICT (followeruserid, followinguserid) DO NOTHING;

WITH device_users AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) LIKE 'device:%'
),
seed_sources AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) IN (
    'mason.rivera25', 'ella.cooper26', 'aiden.ross27',
    'chloe.ward28', 'leo.hunter29', 'grace.morgan30',
    'hudson.cole31', 'stella.ramsey32', 'nora.price24',
    'ethan.sawyer23'
  )
)
INSERT INTO public.followers (followeruserid, followinguserid, createdat, updatedat)
SELECT
  ss.id,
  du.id,
  now(),
  now()
FROM device_users du
JOIN LATERAL (
  SELECT id
  FROM seed_sources ss
  WHERE ss.id <> du.id
  ORDER BY id
  LIMIT 4
) ss ON true
ON CONFLICT (followeruserid, followinguserid) DO NOTHING;

-- Seed followings table from follower graph (idempotent).
INSERT INTO public.followings (userid, followinguserid, createdat, updatedat)
SELECT
  f.followeruserid,
  f.followinguserid,
  now(),
  now()
FROM public.followers f
ON CONFLICT (userid, followinguserid) DO NOTHING;

-- Additional explicit followings for device users.
WITH device_users AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) LIKE 'device:%'
),
target_users AS (
  SELECT id
  FROM public.useraccount
  WHERE lower(username) IN (
    'alex.hayes01', 'jamie.reed02', 'morgan.ellis04',
    'casey.blake06', 'mika.brooks08', 'jordan.flynn10'
  )
)
INSERT INTO public.followings (userid, followinguserid, createdat, updatedat)
SELECT
  du.id,
  tu.id,
  now(),
  now()
FROM device_users du
JOIN target_users tu ON tu.id <> du.id
ON CONFLICT (userid, followinguserid) DO NOTHING;
