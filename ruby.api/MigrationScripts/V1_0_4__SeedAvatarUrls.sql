-- V1_0_4__SeedAvatarUrls.sql
-- Ensures every user profile has a usable fake avatar URL.

-- Create profiles for users missing profile rows.
INSERT INTO public.profiles (userid, displayname, avatarurl, isverified, createdat, updatedat)
SELECT
    u.id,
    u.username,
    'https://i.pravatar.cc/300?u=' || u.id,
    false,
    now(),
    now()
FROM public.useraccount u
LEFT JOIN public.profiles p ON p.userid = u.id
WHERE p.userid IS NULL;

-- Backfill avatar URL for profiles where it is missing/blank.
UPDATE public.profiles p
SET
    avatarurl = 'https://i.pravatar.cc/300?u=' || p.userid,
    updatedat = now()
WHERE p.avatarurl IS NULL
   OR btrim(p.avatarurl) = '';
