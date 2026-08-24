-- V1_0_2__SeedData.sql
-- Seed lookup + fake data for local/dev environments.

-- 1) Seed User Statuses (idempotent)
INSERT INTO public.userstatuses (id, name, description, isactive, sortorder, createdat, updatedat)
VALUES
	('11111111-1111-1111-1111-111111111111', 'Pending',   'Account created but pending verification', true,  10, now(), now()),
	('22222222-2222-2222-2222-222222222222', 'Active',    'Active account',                              true,  20, now(), now()),
	('33333333-3333-3333-3333-333333333333', 'Suspended', 'Temporarily suspended account',              true,  30, now(), now()),
	('44444444-4444-4444-4444-444444444444', 'Blocked',   'Blocked due to policy or abuse',             true,  40, now(), now()),
	('55555555-5555-5555-5555-555555555555', 'Deleted',   'Soft-deleted account',                        false, 50, now(), now())
ON CONFLICT (id) DO UPDATE
SET
	name = EXCLUDED.name,
	description = EXCLUDED.description,
	isactive = EXCLUDED.isactive,
	sortorder = EXCLUDED.sortorder,
	updatedat = now();

-- Also enforce uniqueness by status name if the row already exists with a different id.
UPDATE public.userstatuses
SET
	description = src.description,
	isactive = src.isactive,
	sortorder = src.sortorder,
	updatedat = now()
FROM (
	VALUES
		('Pending',   'Account created but pending verification', true,  10),
		('Active',    'Active account',                              true,  20),
		('Suspended', 'Temporarily suspended account',              true,  30),
		('Blocked',   'Blocked due to policy or abuse',             true,  40),
		('Deleted',   'Soft-deleted account',                        false, 50)
) AS src(name, description, isactive, sortorder)
WHERE lower(public.userstatuses.name) = lower(src.name);


-- 2) Seed 32 fake users (idempotent by username/email)
WITH fake_users AS (
	SELECT *
	FROM (VALUES
		('00000000-0000-0000-0000-000000000001', 'alex.hayes01',   'alex.hayes01@ruby.local',   'Alex',   'Hayes',   1),
		('00000000-0000-0000-0000-000000000002', 'jamie.reed02',   'jamie.reed02@ruby.local',   'Jamie',  'Reed',    1),
		('00000000-0000-0000-0000-000000000003', 'taylor.quinn03', 'taylor.quinn03@ruby.local', 'Taylor', 'Quinn',   1),
		('00000000-0000-0000-0000-000000000004', 'morgan.ellis04', 'morgan.ellis04@ruby.local', 'Morgan', 'Ellis',   1),
		('00000000-0000-0000-0000-000000000005', 'riley.carter05', 'riley.carter05@ruby.local', 'Riley',  'Carter',  1),
		('00000000-0000-0000-0000-000000000006', 'casey.blake06',  'casey.blake06@ruby.local',  'Casey',  'Blake',   1),
		('00000000-0000-0000-0000-000000000007', 'drew.turner07',  'drew.turner07@ruby.local',  'Drew',   'Turner',  1),
		('00000000-0000-0000-0000-000000000008', 'mika.brooks08',  'mika.brooks08@ruby.local',  'Mika',   'Brooks',  1),
		('00000000-0000-0000-0000-000000000009', 'parker.rowan09', 'parker.rowan09@ruby.local', 'Parker', 'Rowan',   1),
		('00000000-0000-0000-0000-00000000000a', 'jordan.flynn10', 'jordan.flynn10@ruby.local', 'Jordan', 'Flynn',   1),
		('00000000-0000-0000-0000-00000000000b', 'avery.moore11',  'avery.moore11@ruby.local',  'Avery',  'Moore',   1),
		('00000000-0000-0000-0000-00000000000c', 'sam.bishop12',   'sam.bishop12@ruby.local',   'Sam',    'Bishop',  1),
		('00000000-0000-0000-0000-00000000000d', 'kai.mitchell13', 'kai.mitchell13@ruby.local', 'Kai',    'Mitchell',1),
		('00000000-0000-0000-0000-00000000000e', 'remy.norris14',  'remy.norris14@ruby.local',  'Remy',   'Norris',  1),
		('00000000-0000-0000-0000-00000000000f', 'logan.perry15',  'logan.perry15@ruby.local',  'Logan',  'Perry',   1),
		('00000000-0000-0000-0000-000000000010', 'sasha.warren16', 'sasha.warren16@ruby.local', 'Sasha',  'Warren',  1),
		('00000000-0000-0000-0000-000000000011', 'noah.barker17',  'noah.barker17@ruby.local',  'Noah',   'Barker',  0),
		('00000000-0000-0000-0000-000000000012', 'zoe.foster18',   'zoe.foster18@ruby.local',   'Zoe',    'Foster',  0),
		('00000000-0000-0000-0000-000000000013', 'liam.keller19',  'liam.keller19@ruby.local',  'Liam',   'Keller',  0),
		('00000000-0000-0000-0000-000000000014', 'ivy.spencer20',  'ivy.spencer20@ruby.local',  'Ivy',    'Spencer', 0),
		('00000000-0000-0000-0000-000000000015', 'owen.taylor21',  'owen.taylor21@ruby.local',  'Owen',   'Taylor',  0),
		('00000000-0000-0000-0000-000000000016', 'luna.bailey22',  'luna.bailey22@ruby.local',  'Luna',   'Bailey',  0),
		('00000000-0000-0000-0000-000000000017', 'ethan.sawyer23', 'ethan.sawyer23@ruby.local', 'Ethan',  'Sawyer',  0),
		('00000000-0000-0000-0000-000000000018', 'nora.price24',   'nora.price24@ruby.local',   'Nora',   'Price',   0),
		('00000000-0000-0000-0000-000000000019', 'mason.rivera25', 'mason.rivera25@ruby.local', 'Mason',  'Rivera',  0),
		('00000000-0000-0000-0000-00000000001a', 'ella.cooper26',  'ella.cooper26@ruby.local',  'Ella',   'Cooper',  0),
		('00000000-0000-0000-0000-00000000001b', 'aiden.ross27',   'aiden.ross27@ruby.local',   'Aiden',  'Ross',    0),
		('00000000-0000-0000-0000-00000000001c', 'chloe.ward28',   'chloe.ward28@ruby.local',   'Chloe',  'Ward',    0),
		('00000000-0000-0000-0000-00000000001d', 'leo.hunter29',   'leo.hunter29@ruby.local',   'Leo',    'Hunter',  0),
		('00000000-0000-0000-0000-00000000001e', 'grace.morgan30', 'grace.morgan30@ruby.local', 'Grace',  'Morgan',  0),
		('00000000-0000-0000-0000-00000000001f', 'hudson.cole31',  'hudson.cole31@ruby.local',  'Hudson', 'Cole',    0),
		('00000000-0000-0000-0000-000000000020', 'stella.ramsey32','stella.ramsey32@ruby.local','Stella', 'Ramsey',  0)
	) AS t(id, username, email, firstname, lastname, status)
)
INSERT INTO public.useraccount (id, username, email, passwordhash, status, createdat, updatedat, lastloginat)
SELECT
	fu.id::uuid,
	fu.username,
	fu.email,
	-- PBKDF2/BCrypt is not needed for seed-only local accounts.
	'seed-password-hash',
	fu.status,
	now(),
	now(),
	now() - ((random() * 45)::int || ' days')::interval
FROM fake_users fu
WHERE NOT EXISTS (
	SELECT 1
	FROM public.useraccount u
	WHERE lower(u.username) = lower(fu.username)
		 OR lower(u.email) = lower(fu.email)
);

-- Keep status aligned even when users already existed from previous runs.
-- Convention used here: 1 = online, 0 = offline.
WITH fake_users AS (
	SELECT *
	FROM (VALUES
		('alex.hayes01',   'alex.hayes01@ruby.local',   1),
		('jamie.reed02',   'jamie.reed02@ruby.local',   1),
		('taylor.quinn03', 'taylor.quinn03@ruby.local', 1),
		('morgan.ellis04', 'morgan.ellis04@ruby.local', 1),
		('riley.carter05', 'riley.carter05@ruby.local', 1),
		('casey.blake06',  'casey.blake06@ruby.local',  1),
		('drew.turner07',  'drew.turner07@ruby.local',  1),
		('mika.brooks08',  'mika.brooks08@ruby.local',  1),
		('parker.rowan09', 'parker.rowan09@ruby.local', 1),
		('jordan.flynn10', 'jordan.flynn10@ruby.local', 1),
		('avery.moore11',  'avery.moore11@ruby.local',  1),
		('sam.bishop12',   'sam.bishop12@ruby.local',   1),
		('kai.mitchell13', 'kai.mitchell13@ruby.local', 1),
		('remy.norris14',  'remy.norris14@ruby.local',  1),
		('logan.perry15',  'logan.perry15@ruby.local',  1),
		('sasha.warren16', 'sasha.warren16@ruby.local', 1),
		('noah.barker17',  'noah.barker17@ruby.local',  0),
		('zoe.foster18',   'zoe.foster18@ruby.local',   0),
		('liam.keller19',  'liam.keller19@ruby.local',  0),
		('ivy.spencer20',  'ivy.spencer20@ruby.local',  0),
		('owen.taylor21',  'owen.taylor21@ruby.local',  0),
		('luna.bailey22',  'luna.bailey22@ruby.local',  0),
		('ethan.sawyer23', 'ethan.sawyer23@ruby.local', 0),
		('nora.price24',   'nora.price24@ruby.local',   0),
		('mason.rivera25', 'mason.rivera25@ruby.local', 0),
		('ella.cooper26',  'ella.cooper26@ruby.local',  0),
		('aiden.ross27',   'aiden.ross27@ruby.local',   0),
		('chloe.ward28',   'chloe.ward28@ruby.local',   0),
		('leo.hunter29',   'leo.hunter29@ruby.local',   0),
		('grace.morgan30', 'grace.morgan30@ruby.local', 0),
		('hudson.cole31',  'hudson.cole31@ruby.local',  0),
		('stella.ramsey32','stella.ramsey32@ruby.local',0)
	) AS t(username, email, status)
)
UPDATE public.useraccount u
SET
	status = fu.status,
	updatedat = now()
FROM fake_users fu
WHERE lower(u.username) = lower(fu.username)
	 OR lower(u.email) = lower(fu.email);


-- 3) Seed matching Profiles for the same 32 fake users
WITH fake_profiles AS (
	SELECT *
	FROM (VALUES
		('00000000-0000-0000-0000-000000000001', 'Alex',   'Hayes'),
		('00000000-0000-0000-0000-000000000002', 'Jamie',  'Reed'),
		('00000000-0000-0000-0000-000000000003', 'Taylor', 'Quinn'),
		('00000000-0000-0000-0000-000000000004', 'Morgan', 'Ellis'),
		('00000000-0000-0000-0000-000000000005', 'Riley',  'Carter'),
		('00000000-0000-0000-0000-000000000006', 'Casey',  'Blake'),
		('00000000-0000-0000-0000-000000000007', 'Drew',   'Turner'),
		('00000000-0000-0000-0000-000000000008', 'Mika',   'Brooks'),
		('00000000-0000-0000-0000-000000000009', 'Parker', 'Rowan'),
		('00000000-0000-0000-0000-00000000000a', 'Jordan', 'Flynn'),
		('00000000-0000-0000-0000-00000000000b', 'Avery',  'Moore'),
		('00000000-0000-0000-0000-00000000000c', 'Sam',    'Bishop'),
		('00000000-0000-0000-0000-00000000000d', 'Kai',    'Mitchell'),
		('00000000-0000-0000-0000-00000000000e', 'Remy',   'Norris'),
		('00000000-0000-0000-0000-00000000000f', 'Logan',  'Perry'),
		('00000000-0000-0000-0000-000000000010', 'Sasha',  'Warren'),
		('00000000-0000-0000-0000-000000000011', 'Noah',   'Barker'),
		('00000000-0000-0000-0000-000000000012', 'Zoe',    'Foster'),
		('00000000-0000-0000-0000-000000000013', 'Liam',   'Keller'),
		('00000000-0000-0000-0000-000000000014', 'Ivy',    'Spencer'),
		('00000000-0000-0000-0000-000000000015', 'Owen',   'Taylor'),
		('00000000-0000-0000-0000-000000000016', 'Luna',   'Bailey'),
		('00000000-0000-0000-0000-000000000017', 'Ethan',  'Sawyer'),
		('00000000-0000-0000-0000-000000000018', 'Nora',   'Price'),
		('00000000-0000-0000-0000-000000000019', 'Mason',  'Rivera'),
		('00000000-0000-0000-0000-00000000001a', 'Ella',   'Cooper'),
		('00000000-0000-0000-0000-00000000001b', 'Aiden',  'Ross'),
		('00000000-0000-0000-0000-00000000001c', 'Chloe',  'Ward'),
		('00000000-0000-0000-0000-00000000001d', 'Leo',    'Hunter'),
		('00000000-0000-0000-0000-00000000001e', 'Grace',  'Morgan'),
		('00000000-0000-0000-0000-00000000001f', 'Hudson', 'Cole'),
		('00000000-0000-0000-0000-000000000020', 'Stella', 'Ramsey')
	) AS t(userid, firstname, lastname)
)
INSERT INTO public.profiles (userid, firstname, lastname, displayname, avatarurl, isverified, createdat, updatedat)
SELECT
	fp.userid::uuid,
	fp.firstname,
	fp.lastname,
	fp.firstname || ' ' || fp.lastname,
	'https://i.pravatar.cc/300?u=' || fp.userid,
	false,
	now(),
	now()
FROM fake_profiles fp
JOIN public.useraccount u ON u.id = fp.userid::uuid
ON CONFLICT (userid) DO UPDATE
SET
	firstname = EXCLUDED.firstname,
	lastname = EXCLUDED.lastname,
	displayname = EXCLUDED.displayname,
	avatarurl = EXCLUDED.avatarurl,
	updatedat = now();
