-- V1_0_0__MasterReferenceTables.sql
-- PostgreSQL migration: create master/reference tables

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure update_timestamp function exists
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updatedat = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Users
CREATE TABLE IF NOT EXISTS public.Users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username varchar(100) NOT NULL,
  email varchar(255) NOT NULL,
  phonenumber varchar(50),
  passwordhash text NOT NULL,
  status smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid,
  lastloginat timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_username ON public.Users (lower(username));
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email ON public.Users (lower(email));
CREATE INDEX IF NOT EXISTS ix_users_status ON public.Users (status);
CREATE INDEX IF NOT EXISTS ix_users_updatedby ON public.Users (updatedby);

-- Common pattern: Id (uuid), Name, Description, IsActive, SortOrder, CreatedAt, UpdatedAt, UpdatedBy

-- UserStatuses
CREATE TABLE IF NOT EXISTS public.userstatuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_userstatuses_name ON public.userstatuses (lower(name));

-- MessageTypes
CREATE TABLE IF NOT EXISTS public.messagetypes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_messagetypes_name ON public.messagetypes (lower(name));

-- MessageStatuses
CREATE TABLE IF NOT EXISTS public.messagestatuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_messagestatuses_name ON public.messagestatuses (lower(name));

-- CallStatuses
CREATE TABLE IF NOT EXISTS public.callstatuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_callstatuses_name ON public.callstatuses (lower(name));

-- PaymentStatuses
CREATE TABLE IF NOT EXISTS public.paymentstatuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_paymentstatuses_name ON public.paymentstatuses (lower(name));

-- WalletTransactionTypes
CREATE TABLE IF NOT EXISTS public.wallettransactiontypes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(100) NOT NULL,
  description varchar(200),
  direction varchar(20),
  affectsbalance boolean NOT NULL DEFAULT true,
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_wallettransactiontypes_name ON public.wallettransactiontypes (lower(name));

-- Genders
CREATE TABLE IF NOT EXISTS public.genders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_genders_name ON public.genders (lower(name));

-- UserRoles
CREATE TABLE IF NOT EXISTS public.userroles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_userroles_name ON public.userroles (lower(name));

-- NotificationTypes
CREATE TABLE IF NOT EXISTS public.notificationtypes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(100) NOT NULL,
  description varchar(200),
  requirespushnotification boolean NOT NULL DEFAULT false,
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_notificationtypes_name ON public.notificationtypes (lower(name));

-- CallTypes
CREATE TABLE IF NOT EXISTS public.calltypes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(50) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_calltypes_name ON public.calltypes (lower(name));

-- Countries
CREATE TABLE IF NOT EXISTS public.countries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(150) NOT NULL,
  isocode varchar(10),
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_countries_name ON public.countries (lower(name));

-- Languages
CREATE TABLE IF NOT EXISTS public.languages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(100) NOT NULL,
  isocode varchar(10),
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_languages_name ON public.languages (lower(name));

-- GiftCategories
CREATE TABLE IF NOT EXISTS public.giftcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(150) NOT NULL,
  description varchar(200),
  isactive boolean NOT NULL DEFAULT true,
  sortorder smallint NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_giftcategories_name ON public.giftcategories (lower(name));

-- Add UpdatedBy foreign keys referencing Users(Id)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_userstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public.userstatuses ADD CONSTRAINT fk_userstatuses_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messagetypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public.messagetypes ADD CONSTRAINT fk_messagetypes_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messagestatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public.messagestatuses ADD CONSTRAINT fk_messagestatuses_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public.callstatuses ADD CONSTRAINT fk_callstatuses_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paymentstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public.paymentstatuses ADD CONSTRAINT fk_paymentstatuses_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactiontypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public.wallettransactiontypes ADD CONSTRAINT fk_wallettransactiontypes_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_genders_updatedby') THEN
	EXECUTE 'ALTER TABLE public.genders ADD CONSTRAINT fk_genders_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_userroles_updatedby') THEN
	EXECUTE 'ALTER TABLE public.userroles ADD CONSTRAINT fk_userroles_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notificationtypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public.notificationtypes ADD CONSTRAINT fk_notificationtypes_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calltypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public.calltypes ADD CONSTRAINT fk_calltypes_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;
END;
$$;

-- Attach update triggers to all master tables
DROP TRIGGER IF EXISTS trg_userstatuses_update_timestamp ON public.userstatuses;
CREATE TRIGGER trg_userstatuses_update_timestamp
BEFORE UPDATE ON public.userstatuses
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messagetypes_update_timestamp ON public.messagetypes;
CREATE TRIGGER trg_messagetypes_update_timestamp
BEFORE UPDATE ON public.messagetypes
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messagestatuses_update_timestamp ON public.messagestatuses;
CREATE TRIGGER trg_messagestatuses_update_timestamp
BEFORE UPDATE ON public.messagestatuses
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_callstatuses_update_timestamp ON public.callstatuses;
CREATE TRIGGER trg_callstatuses_update_timestamp
BEFORE UPDATE ON public.callstatuses
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_paymentstatuses_update_timestamp ON public.paymentstatuses;
CREATE TRIGGER trg_paymentstatuses_update_timestamp
BEFORE UPDATE ON public.paymentstatuses
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallettransactiontypes_update_timestamp ON public.wallettransactiontypes;
CREATE TRIGGER trg_wallettransactiontypes_update_timestamp
BEFORE UPDATE ON public.wallettransactiontypes
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_genders_update_timestamp ON public.genders;
CREATE TRIGGER trg_genders_update_timestamp
BEFORE UPDATE ON public.genders
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_userroles_update_timestamp ON public.userroles;
CREATE TRIGGER trg_userroles_update_timestamp
BEFORE UPDATE ON public.userroles
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_notificationtypes_update_timestamp ON public.notificationtypes;
CREATE TRIGGER trg_notificationtypes_update_timestamp
BEFORE UPDATE ON public.notificationtypes
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_calltypes_update_timestamp ON public.calltypes;
CREATE TRIGGER trg_calltypes_update_timestamp
BEFORE UPDATE ON public.calltypes
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
