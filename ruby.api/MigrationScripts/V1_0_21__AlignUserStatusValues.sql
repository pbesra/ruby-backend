-- V1_0_21__AlignUserStatusValues.sql
-- Create a dedicated status lookup table and attach it to profiles via a foreign key.

ALTER TABLE public.profiles
    DROP CONSTRAINT IF EXISTS chk_profiles_statusname;
ALTER TABLE public.profiles
    DROP COLUMN IF EXISTS statusname;

CREATE TABLE IF NOT EXISTS public.status (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(30) NOT NULL UNIQUE,
    description varchar(200),
    isactive boolean NOT NULL DEFAULT true,
    sortorder smallint NOT NULL DEFAULT 0,
    createdat timestamptz NOT NULL DEFAULT now(),
    updatedat timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.status (id, name, description, isactive, sortorder, createdat, updatedat)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'online', 'User is online', true, 10, now(), now()),
    ('22222222-2222-2222-2222-222222222222', 'live', 'User is live', true, 20, now(), now()),
    ('33333333-3333-3333-3333-333333333333', 'busy', 'User is busy', true, 30, now(), now()),
    ('44444444-4444-4444-4444-444444444444', 'away', 'User is away', true, 40, now(), now()),
    ('55555555-5555-5555-5555-555555555555', 'party', 'User is in party mode', true, 50, now(), now()),
    ('66666666-6666-6666-6666-666666666666', 'offline', 'User is offline', true, 60, now(), now())
ON CONFLICT (name) DO UPDATE
SET description = EXCLUDED.description,
    isactive = EXCLUDED.isactive,
    sortorder = EXCLUDED.sortorder,
    updatedat = now();

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS statusid uuid;

ALTER TABLE public.profiles
    ADD CONSTRAINT fk_profiles_status
    FOREIGN KEY (statusid) REFERENCES public.status(id) ON DELETE SET NULL;

UPDATE public.profiles p
SET statusid = CASE
    WHEN u.status = 1 THEN (SELECT id FROM public.status WHERE lower(name) = 'online')
    WHEN u.status = 2 THEN (SELECT id FROM public.status WHERE lower(name) = 'live')
    WHEN u.status = 3 THEN (SELECT id FROM public.status WHERE lower(name) = 'busy')
    WHEN u.status = 4 THEN (SELECT id FROM public.status WHERE lower(name) = 'party')
    WHEN u.status = 0 THEN (SELECT id FROM public.status WHERE lower(name) = 'offline')
    ELSE (SELECT id FROM public.status WHERE lower(name) = 'away')
END
FROM public.useraccount u
WHERE p.userid = u.id
  AND p.statusid IS NULL;
