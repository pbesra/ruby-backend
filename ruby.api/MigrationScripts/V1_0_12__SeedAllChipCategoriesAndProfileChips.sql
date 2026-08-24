-- V1_0_12__SeedAllChipCategoriesAndProfileChips.sql
-- Ensure every chip category has master chip data and every profile gets one chip from each active category.

INSERT INTO public.chipcategories (id, name, code, isactive, sortorder)
SELECT v.id::uuid, v.name, v.code, v.isactive::boolean, v.sortorder::integer
FROM (
    VALUES
        ('d0000000-0000-0000-0000-000000000001'::uuid, 'Language'::text, 'language'::text, true, 10),
        ('d0000000-0000-0000-0000-000000000003'::uuid, 'Preference'::text, 'preference'::text, true, 30),
        ('d0000000-0000-0000-0000-000000000004'::uuid, 'Personality'::text, 'personality'::text, true, 40),
        ('d0000000-0000-0000-0000-000000000005'::uuid, 'Interest'::text, 'interest'::text, true, 50)
) AS v(id, name, code, isactive, sortorder)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.chipcategories cc
    WHERE lower(cc.name) = lower(v.name)
       OR lower(cc.code) = lower(v.code)
);

UPDATE public.chipcategories cc
SET
    name = v.name,
    code = v.code,
    isactive = v.isactive,
    sortorder = v.sortorder
FROM (
    VALUES
        ('d0000000-0000-0000-0000-000000000001', 'Language', 'language', true, 10),
        ('d0000000-0000-0000-0000-000000000003', 'Preference', 'preference', true, 30),
        ('d0000000-0000-0000-0000-000000000004', 'Personality', 'personality', true, 40),
        ('d0000000-0000-0000-0000-000000000005', 'Interest', 'interest', true, 50)
) AS v(id, name, code, isactive, sortorder)
WHERE cc.id = v.id::uuid;

INSERT INTO public.chips (id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
SELECT v.id::uuid, v.chipcategoryid::uuid, v.name, v.code,
       COALESCE(NULLIF(trim(v.avatarurl), ''), 'https://api.dicebear.com/7.x/initials/svg?seed=' || replace(lower(v.name), ' ', '+')),
       v.description, v.sortorder::integer, v.isactive::boolean, v.createdat
FROM (
    VALUES
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'English'::text, 'english'::text, 'assets/icons/chips/language.svg', 'Language chip for English'::text, 10, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'Hindi'::text, 'hindi'::text, 'assets/icons/chips/language.svg', 'Language chip for Hindi'::text, 20, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'Spanish'::text, 'spanish'::text, 'assets/icons/chips/language.svg', 'Language chip for Spanish'::text, 30, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'French'::text, 'french'::text, 'assets/icons/chips/language.svg', 'Language chip for French'::text, 40, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'German'::text, 'german'::text, 'assets/icons/chips/language.svg', 'Language chip for German'::text, 50, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'Japanese'::text, 'japanese'::text, 'assets/icons/chips/language.svg', 'Language chip for Japanese'::text, 60, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000001'::uuid, 'Arabic'::text, 'arabic'::text, 'assets/icons/chips/language.svg', 'Language chip for Arabic'::text, 70, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000003'::uuid, 'Seeking Friends'::text, 'seeking-friends'::text, 'assets/icons/chips/preference.svg', 'Preference chip for seeking friends'::text, 10, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000003'::uuid, 'Looking for a Relationship'::text, 'looking-for-a-relationship'::text, 'assets/icons/chips/preference.svg', 'Preference chip for looking for a relationship'::text, 20, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000003'::uuid, 'Casual Chat'::text, 'casual-chat'::text, 'assets/icons/chips/preference.svg', 'Preference chip for casual chat'::text, 30, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000003'::uuid, 'Travel Buddy'::text, 'travel-buddy'::text, 'assets/icons/chips/preference.svg', 'Preference chip for travel buddy'::text, 40, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000003'::uuid, 'Local Meetups'::text, 'local-meetups'::text, 'assets/icons/chips/preference.svg', 'Preference chip for local meetups'::text, 50, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Introvert'::text, 'introvert'::text, 'assets/icons/chips/personality.svg', 'Personality chip for introvert'::text, 10, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Extrovert'::text, 'extrovert'::text, 'assets/icons/chips/personality.svg', 'Personality chip for extrovert'::text, 20, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Fun-loving'::text, 'fun-loving'::text, 'assets/icons/chips/personality.svg', 'Personality chip for fun-loving'::text, 30, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Thoughtful'::text, 'thoughtful'::text, 'assets/icons/chips/personality.svg', 'Personality chip for thoughtful'::text, 40, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Adventurous'::text, 'adventurous'::text, 'assets/icons/chips/personality.svg', 'Personality chip for adventurous'::text, 50, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000004'::uuid, 'Calm'::text, 'calm'::text, 'assets/icons/chips/personality.svg', 'Personality chip for calm'::text, 60, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Film Lover'::text, 'film-lover'::text, 'assets/icons/chips/interest.svg', 'Interest chip for film lover'::text, 10, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Dancing'::text, 'dancing'::text, 'assets/icons/chips/interest.svg', 'Interest chip for dancing'::text, 20, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Dog Lover'::text, 'dog-lover'::text, 'assets/icons/chips/interest.svg', 'Interest chip for dog lover'::text, 30, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Singing'::text, 'singing'::text, 'assets/icons/chips/interest.svg', 'Interest chip for singing'::text, 40, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Travelling'::text, 'travelling'::text, 'assets/icons/chips/interest.svg', 'Interest chip for travelling'::text, 50, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Reading'::text, 'reading'::text, 'assets/icons/chips/interest.svg', 'Interest chip for reading'::text, 60, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Fitness'::text, 'fitness'::text, 'assets/icons/chips/interest.svg', 'Interest chip for fitness'::text, 70, true, now()),
        (gen_random_uuid(), 'd0000000-0000-0000-0000-000000000005'::uuid, 'Cooking'::text, 'cooking'::text, 'assets/icons/chips/interest.svg', 'Interest chip for cooking'::text, 80, true, now())
) AS v(id, chipcategoryid, name, code, avatarurl, description, sortorder, isactive, createdat)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.chips c
    WHERE lower(c.name) = lower(v.name)
);

WITH ranked_profile_chips AS (
    SELECT
        p.userid AS profileid,
        cc.code AS categorycode,
        c.id AS chipid,
        ROW_NUMBER() OVER (
            PARTITION BY p.userid, cc.code
            ORDER BY ((abs(hashtext(p.userid::text || '|' || cc.code || '|' || c.name)) + c.sortorder) % 1000), c.name
        ) AS seq
    FROM public.profiles p
    JOIN public.chipcategories cc ON cc.isactive = true
    JOIN public.chips c ON c.chipcategoryid = cc.id
    WHERE cc.code IN ('language', 'preference', 'personality', 'interest')
      AND c.isactive = true
)
INSERT INTO public.profilechips (id, profileid, chipid, createdat)
SELECT
    gen_random_uuid(),
    rpc.profileid,
    rpc.chipid,
    now()
FROM ranked_profile_chips rpc
WHERE (rpc.categorycode = 'language' AND rpc.seq = 1)
   OR (rpc.categorycode IN ('preference', 'personality', 'interest') AND rpc.seq <= 2)
ON CONFLICT (profileid, chipid) DO NOTHING;
