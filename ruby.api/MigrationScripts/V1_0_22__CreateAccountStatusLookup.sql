-- V1_0_22__CreateAccountStatusLookup.sql
-- Create a dedicated account status lookup table and attach it to useraccount via a foreign key.

CREATE TABLE IF NOT EXISTS public.accountstatus (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code varchar(30) NOT NULL UNIQUE,
    name varchar(50) NOT NULL UNIQUE,
    description varchar(200),
    isactive boolean NOT NULL DEFAULT true,
    sortorder smallint NOT NULL DEFAULT 0,
    createdat timestamptz NOT NULL DEFAULT now(),
    updatedat timestamptz NOT NULL DEFAULT now(),
    updatedby uuid
);

INSERT INTO public.accountstatus (id, code, name, description, isactive, sortorder, createdat, updatedat)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'disabled', 'Disabled', 'Account is disabled', true, 10, now(), now()),
    ('22222222-2222-2222-2222-222222222222', 'active', 'Active', 'Account is active', true, 20, now(), now()),
    ('33333333-3333-3333-3333-333333333333', 'suspended', 'Suspended', 'Account is suspended', true, 30, now(), now()),
    ('44444444-4444-4444-4444-444444444444', 'blocked', 'Blocked', 'Account is blocked', true, 40, now(), now()),
    ('55555555-5555-5555-5555-555555555555', 'verified', 'Verified', 'Account is verified', true, 50, now(), now()),
    ('66666666-6666-6666-6666-666666666666', 'notverified', 'NotVerified', 'Account is not verified yet', true, 60, now(), now()),
    ('77777777-7777-7777-7777-777777777777', 'pending', 'Pending', 'Account is pending review', true, 70, now(), now())
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    isactive = EXCLUDED.isactive,
    sortorder = EXCLUDED.sortorder,
    updatedat = now();

-- Keep the lookup table aligned if a legacy row already exists with the same name but a different code.
UPDATE public.accountstatus AS a
SET name = src.name,
    description = src.description,
    isactive = src.isactive,
    sortorder = src.sortorder,
    updatedat = now()
FROM (
    VALUES
        ('disabled', 'Disabled', 'Account is disabled', true, 10),
        ('active', 'Active', 'Account is active', true, 20),
        ('suspended', 'Suspended', 'Account is suspended', true, 30),
        ('blocked', 'Blocked', 'Account is blocked', true, 40),
        ('verified', 'Verified', 'Account is verified', true, 50),
        ('notverified', 'NotVerified', 'Account is not verified yet', true, 60),
        ('pending', 'Pending', 'Account is pending review', true, 70)
) AS src(code, name, description, isactive, sortorder)
WHERE lower(a.code) = lower(src.code)
   OR lower(a.name) = lower(src.name);

ALTER TABLE public.useraccount
    ADD COLUMN IF NOT EXISTS accountstatusid uuid;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_useraccount_accountstatus'
    ) THEN
        ALTER TABLE public.useraccount
            ADD CONSTRAINT fk_useraccount_accountstatus
            FOREIGN KEY (accountstatusid) REFERENCES public.accountstatus(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_useraccount_accountstatusid
    ON public.useraccount (accountstatusid);

UPDATE public.useraccount u
SET accountstatusid = CASE
    WHEN lower(COALESCE(u.username, '')) LIKE '%pending%' THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'pending')
    WHEN u.status = 0 THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'disabled')
    WHEN u.status = 1 THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'active')
    WHEN u.status = 2 THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'suspended')
    WHEN u.status = 3 THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'blocked')
    WHEN u.status = 4 THEN (SELECT id FROM public.accountstatus WHERE lower(code) = 'verified')
    ELSE (SELECT id FROM public.accountstatus WHERE lower(code) = 'notverified')
END
WHERE u.accountstatusid IS NULL
   OR NOT EXISTS (
       SELECT 1
       FROM public.accountstatus a
       WHERE a.id = u.accountstatusid
   );
