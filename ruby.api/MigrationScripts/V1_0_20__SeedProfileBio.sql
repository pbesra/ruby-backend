-- V1_0_13__SeedProfileBio.sql
-- Seed a bio for each profile that does not already have one so the profile card can render real data.

WITH bio_pool AS (
    SELECT value, rn
    FROM (
        VALUES
            ('I am feeling very lonely, please call me and help me in removing my loneliness.', 1),
            ('I enjoy warm conversations and meaningful connections over coffee and long walks.', 2),
            ('Looking for genuine laughs, deep talks, and someone to share life with.', 3),
            ('I love travelling, good food, and meeting people with kind hearts.', 4),
            ('I am here to make new friends, share stories, and enjoy peaceful moments.', 5),
            ('I like thoughtful conversations, adventure, and real human connection.', 6)
    ) AS v(value, rn)
),
profile_bios AS (
    SELECT
        p.userid,
        bp.value AS bio_value,
        ((abs(hashtext(p.userid::text)) % (SELECT count(*) FROM bio_pool)) + 1) AS pool_index
    FROM public.profiles p
    CROSS JOIN bio_pool bp
    WHERE (p.bio IS NULL OR trim(p.bio) = '')
      AND bp.rn = ((abs(hashtext(p.userid::text)) % (SELECT count(*) FROM bio_pool)) + 1)
)
UPDATE public.profiles p
SET bio = pb.bio_value,
    updatedat = now()
FROM profile_bios pb
WHERE p.userid = pb.userid;
