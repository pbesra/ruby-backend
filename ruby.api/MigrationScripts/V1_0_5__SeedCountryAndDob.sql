-- V1_0_5__SeedCountryAndDob.sql
-- Seed country and language reference data, then backfill address and DOB for profile card metadata.

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

INSERT INTO public.languages (id, name, isocode, description, isactive, sortorder, createdat, updatedat)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'English', 'en', 'English', true, 10, now(), now()),
    ('a0000000-0000-0000-0000-000000000002', 'Hindi', 'hi', 'Hindi', true, 20, now(), now()),
    ('a0000000-0000-0000-0000-000000000003', 'Spanish', 'es', 'Spanish', true, 30, now(), now()),
    ('a0000000-0000-0000-0000-000000000004', 'French', 'fr', 'French', true, 40, now(), now()),
    ('a0000000-0000-0000-0000-000000000005', 'German', 'de', 'German', true, 50, now(), now()),
    ('a0000000-0000-0000-0000-000000000006', 'Japanese', 'ja', 'Japanese', true, 60, now(), now()),
    ('a0000000-0000-0000-0000-000000000007', 'Arabic', 'ar', 'Arabic', true, 70, now(), now())
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    isocode = EXCLUDED.isocode,
    description = EXCLUDED.description,
    isactive = EXCLUDED.isactive,
    sortorder = EXCLUDED.sortorder,
    updatedat = now();

INSERT INTO public.chipcategories (id, name, code, isactive, sortorder)
SELECT v.id, v.name, v.code, v.isactive, v.sortorder
FROM (
    VALUES
        ('b0000000-0000-0000-0000-000000000001'::uuid, 'Language'::text, 'language'::text, true, 10),
        ('b0000000-0000-0000-0000-000000000002'::uuid, 'Location'::text, 'location'::text, true, 20),
        ('b0000000-0000-0000-0000-000000000003'::uuid, 'Preference'::text, 'preference'::text, true, 30),
        ('b0000000-0000-0000-0000-000000000004'::uuid, 'Personality'::text, 'personality'::text, true, 40),
        ('b0000000-0000-0000-0000-000000000005'::uuid, 'Interest'::text, 'interest'::text, true, 50)
) AS v(id, name, code, isactive, sortorder)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.chipcategories cc
    WHERE lower(cc.name) = lower(v.name)
       OR lower(cc.code) = lower(v.code)
);

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
SELECT gen_random_uuid(), cc.id, l.name,
       lower(regexp_replace(l.name, '[^a-zA-Z0-9]+', '-', 'g')),
       NULL,
       'Language chip for ' || l.name,
       l.sortorder,
       true,
       now()
FROM public.languages l
JOIN public.chipcategories cc ON cc.code = 'language'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.chips ch
    WHERE ch.chipcategoryid = cc.id
      AND lower(ch.name) = lower(l.name)
);

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
VALUES
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'New Delhi', 'new-delhi', NULL, 'Location chip for New Delhi', 10, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'New York', 'new-york', NULL, 'Location chip for New York', 20, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'London', 'london', NULL, 'Location chip for London', 30, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'Dubai', 'dubai', NULL, 'Location chip for Dubai', 40, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'Singapore', 'singapore', NULL, 'Location chip for Singapore', 50, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'Paris', 'paris', NULL, 'Location chip for Paris', 60, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'Tokyo', 'tokyo', NULL, 'Location chip for Tokyo', 70, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 'Sydney', 'sydney', NULL, 'Location chip for Sydney', 80, true, now())
ON CONFLICT DO NOTHING;

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
VALUES
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000003', 'Seeking Friends', 'seeking-friends', NULL, 'Preference chip for seeking friends', 10, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000003', 'Looking for a Relationship', 'looking-for-a-relationship', NULL, 'Preference chip for looking for a relationship', 20, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000003', 'Casual Chat', 'casual-chat', NULL, 'Preference chip for casual chat', 30, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000003', 'Travel Buddy', 'travel-buddy', NULL, 'Preference chip for travel buddy', 40, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000003', 'Local Meetups', 'local-meetups', NULL, 'Preference chip for local meetups', 50, true, now())
ON CONFLICT DO NOTHING;

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
VALUES
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Introvert', 'introvert', NULL, 'Personality chip for introvert', 10, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Extrovert', 'extrovert', NULL, 'Personality chip for extrovert', 20, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Fun-loving', 'fun-loving', NULL, 'Personality chip for fun-loving', 30, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Thoughtful', 'thoughtful', NULL, 'Personality chip for thoughtful', 40, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Adventurous', 'adventurous', NULL, 'Personality chip for adventurous', 50, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000004', 'Calm', 'calm', NULL, 'Personality chip for calm', 60, true, now())
ON CONFLICT DO NOTHING;

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
VALUES
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Film Lover', 'film-lover', NULL, 'Interest chip for film lover', 10, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Dancing', 'dancing', NULL, 'Interest chip for dancing', 20, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Dog Lover', 'dog-lover', NULL, 'Interest chip for dog lover', 30, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Singing', 'singing', NULL, 'Interest chip for singing', 40, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Travelling', 'travelling', NULL, 'Interest chip for travelling', 50, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Reading', 'reading', NULL, 'Interest chip for reading', 60, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Fitness', 'fitness', NULL, 'Interest chip for fitness', 70, true, now()),
    (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000005', 'Cooking', 'cooking', NULL, 'Interest chip for cooking', 80, true, now())
ON CONFLICT DO NOTHING;

WITH profile_country_seed AS (
    SELECT
        p.userid,
        CASE
            WHEN abs(hashtext(p.userid::text)) % 10 = 0 THEN '90000000-0000-0000-0000-000000000001'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 1 THEN '90000000-0000-0000-0000-000000000002'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 2 THEN '90000000-0000-0000-0000-000000000003'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 3 THEN '90000000-0000-0000-0000-000000000004'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 4 THEN '90000000-0000-0000-0000-000000000005'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 5 THEN '90000000-0000-0000-0000-000000000006'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 6 THEN '90000000-0000-0000-0000-000000000007'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 7 THEN '90000000-0000-0000-0000-000000000008'::uuid
            WHEN abs(hashtext(p.userid::text)) % 10 = 8 THEN '90000000-0000-0000-0000-000000000009'::uuid
            ELSE '90000000-0000-0000-0000-00000000000a'::uuid
        END AS country_id,
        CASE
            WHEN abs(hashtext(p.userid::text)) % 10 = 0 THEN 'New Delhi'
            WHEN abs(hashtext(p.userid::text)) % 10 = 1 THEN 'New York'
            WHEN abs(hashtext(p.userid::text)) % 10 = 2 THEN 'London'
            WHEN abs(hashtext(p.userid::text)) % 10 = 3 THEN 'Toronto'
            WHEN abs(hashtext(p.userid::text)) % 10 = 4 THEN 'Sydney'
            WHEN abs(hashtext(p.userid::text)) % 10 = 5 THEN 'Berlin'
            WHEN abs(hashtext(p.userid::text)) % 10 = 6 THEN 'Paris'
            WHEN abs(hashtext(p.userid::text)) % 10 = 7 THEN 'Tokyo'
            WHEN abs(hashtext(p.userid::text)) % 10 = 8 THEN 'Singapore'
            ELSE 'Dubai'
        END AS city_name,
        CASE
            WHEN abs(hashtext(p.userid::text)) % 10 = 0 THEN 'IN'
            WHEN abs(hashtext(p.userid::text)) % 10 = 1 THEN 'US'
            WHEN abs(hashtext(p.userid::text)) % 10 = 2 THEN 'GB'
            WHEN abs(hashtext(p.userid::text)) % 10 = 3 THEN 'CA'
            WHEN abs(hashtext(p.userid::text)) % 10 = 4 THEN 'AU'
            WHEN abs(hashtext(p.userid::text)) % 10 = 5 THEN 'DE'
            WHEN abs(hashtext(p.userid::text)) % 10 = 6 THEN 'FR'
            WHEN abs(hashtext(p.userid::text)) % 10 = 7 THEN 'JP'
            WHEN abs(hashtext(p.userid::text)) % 10 = 8 THEN 'SG'
            ELSE 'AE'
        END AS country_code
    FROM public.profiles p
    WHERE p.addressid IS NULL
)
INSERT INTO public.addresses (id, city, state, postalcode, country, countrycode, createdat, updatedat)
SELECT
    gen_random_uuid(),
    pcs.city_name,
    '',
    '',
    c.name,
    pcs.country_code,
    now(),
    now()
FROM profile_country_seed pcs
JOIN public.countries c ON c.id = pcs.country_id
ON CONFLICT DO NOTHING;

WITH profile_address_seed AS (
    SELECT
        p.userid,
        a.id AS addressid
    FROM public.profiles p
    JOIN public.addresses a
      ON a.city = CASE
            WHEN abs(hashtext(p.userid::text)) % 10 = 0 THEN 'New Delhi'
            WHEN abs(hashtext(p.userid::text)) % 10 = 1 THEN 'New York'
            WHEN abs(hashtext(p.userid::text)) % 10 = 2 THEN 'London'
            WHEN abs(hashtext(p.userid::text)) % 10 = 3 THEN 'Toronto'
            WHEN abs(hashtext(p.userid::text)) % 10 = 4 THEN 'Sydney'
            WHEN abs(hashtext(p.userid::text)) % 10 = 5 THEN 'Berlin'
            WHEN abs(hashtext(p.userid::text)) % 10 = 6 THEN 'Paris'
            WHEN abs(hashtext(p.userid::text)) % 10 = 7 THEN 'Tokyo'
            WHEN abs(hashtext(p.userid::text)) % 10 = 8 THEN 'Singapore'
            ELSE 'Dubai'
        END
    WHERE p.addressid IS NULL
)
UPDATE public.profiles p
SET addressid = pas.addressid,
    updatedat = now()
FROM profile_address_seed pas
WHERE p.userid = pas.userid
  AND p.addressid IS NULL;

WITH language_pool AS (
    SELECT id, row_number() OVER (ORDER BY isocode) AS rn,
           count(*) OVER () AS total
    FROM public.languages
    WHERE isactive = true
)
UPDATE public.profiles p
SET language = (
    SELECT lp.id
    FROM language_pool lp
    WHERE lp.rn = ((abs(hashtext(p.userid::text)) % (SELECT total FROM language_pool ORDER BY total DESC LIMIT 1)) + 1)
),
    updatedat = now()
WHERE p.language IS NULL;

WITH current_profile_addresses AS (
    SELECT
        p.userid AS profileid,
        p.addressid,
        ROW_NUMBER() OVER (PARTITION BY p.userid ORDER BY p.updatedat DESC) AS rn
    FROM public.profiles p
    WHERE p.addressid IS NOT NULL
)
INSERT INTO public.profileaddresses (id, profileid, addressid, isprimary, iscurrent, createdat, updatedat)
SELECT
    gen_random_uuid(),
    cpa.profileid,
    cpa.addressid,
    true,
    true,
    now(),
    now()
FROM current_profile_addresses cpa
WHERE cpa.rn = 1
ON CONFLICT DO NOTHING;

WITH default_image_seed AS (
    SELECT
        p.userid AS profileid,
        CONCAT('https://i.pravatar.cc/300?u=', p.userid::text) AS imageurl,
        ROW_NUMBER() OVER (PARTITION BY p.userid ORDER BY p.updatedat DESC) AS rn
    FROM public.profiles p
)
INSERT INTO public.profileimages (id, profileid, imageurl, isdefault, isactive, createdat, updatedat)
SELECT
    gen_random_uuid(),
    dis.profileid,
    dis.imageurl,
    true,
    true,
    now(),
    now()
FROM default_image_seed dis
WHERE dis.rn = 1
ON CONFLICT DO NOTHING;

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

INSERT INTO public.profilechips (id, profileid, chipid, createdat)
SELECT DISTINCT
    gen_random_uuid(),
    p.userid,
    c.id,
    now()
FROM public.profiles p
JOIN public.languages l ON l.id = p.language
JOIN public.chips c ON c.chipcategoryid = (
    SELECT cc.id
    FROM public.chipcategories cc
    WHERE cc.code = 'language'
)
WHERE lower(c.name) = lower(l.name)
  AND NOT EXISTS (
      SELECT 1
      FROM public.profilechips pc
      WHERE pc.profileid = p.userid
        AND pc.chipid = c.id
  );
