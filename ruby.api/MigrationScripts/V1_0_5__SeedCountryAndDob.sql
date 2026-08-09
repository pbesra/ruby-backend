-- V1_0_5__SeedCountryAndDob.sql
-- Seed country reference data and backfill profile country + DOB for card metadata.

INSERT INTO public.countries (id, name, isocode, description, isactive, sortorder, createdat, updatedat)
VALUES
    ('90000000-0000-0000-0000-000000000001', 'India', 'IN', 'India', true, 10, now(), now()),
    ('90000000-0000-0000-0000-000000000002', 'United States', 'US', 'United States', true, 20, now(), now()),
    ('90000000-0000-0000-0000-000000000003', 'United Kingdom', 'GB', 'United Kingdom', true, 30, now(), now()),
    ('90000000-0000-0000-0000-000000000004', 'Canada', 'CA', 'Canada', true, 40, now(), now()),
    ('90000000-0000-0000-0000-000000000005', 'Australia', 'AU', 'Australia', true, 50, now(), now()),
    ('90000000-0000-0000-0000-000000000006', 'Germany', 'DE', 'Germany', true, 60, now(), now()),
    ('90000000-0000-0000-0000-000000000007', 'France', 'FR', 'France', true, 70, now(), now()),
    ('90000000-0000-0000-0000-000000000008', 'Japan', 'JP', 'Japan', true, 80, now(), now()),
    ('90000000-0000-0000-0000-000000000009', 'Singapore', 'SG', 'Singapore', true, 90, now(), now()),
    ('90000000-0000-0000-0000-00000000000a', 'United Arab Emirates', 'AE', 'United Arab Emirates', true, 100, now(), now())
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    isocode = EXCLUDED.isocode,
    description = EXCLUDED.description,
    isactive = EXCLUDED.isactive,
    sortorder = EXCLUDED.sortorder,
    updatedat = now();

-- Ensure each profile has a country mapped from deterministic user-id hash.
WITH country_pool AS (
    SELECT
        c.id,
        row_number() OVER (ORDER BY lower(c.isocode)) AS rn,
        count(*) OVER () AS cnt
    FROM public.countries c
    WHERE upper(c.isocode) IN ('IN', 'US', 'GB', 'CA', 'AU', 'DE', 'FR', 'JP', 'SG', 'AE')
)
UPDATE public.profiles p
SET
    country = (
        SELECT cp.id
        FROM country_pool cp
        WHERE cp.rn = ((get_byte(decode(replace(p.userid::text, '-', ''), 'hex'), 15) % (SELECT max(rn) FROM country_pool)) + 1)
    ),
    updatedat = now()
WHERE p.country IS NULL;

-- Backfill DOB for users missing DOB, yielding an age range roughly 21-32.
UPDATE public.profiles p
SET
    dob = (
        date '1994-01-01' +
        ((get_byte(decode(replace(p.userid::text, '-', ''), 'hex'), 14) * 37
          + get_byte(decode(replace(p.userid::text, '-', ''), 'hex'), 15)) % 4380) * interval '1 day'
    )::date,
    updatedat = now()
WHERE p.dob IS NULL;
