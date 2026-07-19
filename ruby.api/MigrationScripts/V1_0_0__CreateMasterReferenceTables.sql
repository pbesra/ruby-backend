-- V1_0_0__MasterReferenceTables.sql
-- PostgreSQL migration: create master/reference tables

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure update_timestamp function exists
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW."UpdatedAt" = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Users
CREATE TABLE IF NOT EXISTS public."Users" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "UserName" varchar(100) NOT NULL,
  "Email" varchar(255) NOT NULL,
  "PhoneNumber" varchar(50),
  "PasswordHash" text NOT NULL,
  "Status" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid,
  "LastLoginAt" timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_username ON public."Users" (lower("UserName"));
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email ON public."Users" (lower("Email"));
CREATE INDEX IF NOT EXISTS ix_users_status ON public."Users" ("Status");
CREATE INDEX IF NOT EXISTS ix_users_updatedby ON public."Users" ("UpdatedBy");

-- Common pattern: Id (uuid), Name, Description, IsActive, SortOrder, CreatedAt, UpdatedAt, UpdatedBy

-- UserStatuses
CREATE TABLE IF NOT EXISTS public."UserStatuses" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_userstatuses_name ON public."UserStatuses" (lower("Name"));

-- MessageTypes
CREATE TABLE IF NOT EXISTS public."MessageTypes" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_messagetypes_name ON public."MessageTypes" (lower("Name"));

-- MessageStatuses
CREATE TABLE IF NOT EXISTS public."MessageStatuses" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_messagestatuses_name ON public."MessageStatuses" (lower("Name"));

-- CallStatuses
CREATE TABLE IF NOT EXISTS public."CallStatuses" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_callstatuses_name ON public."CallStatuses" (lower("Name"));

-- PaymentStatuses
CREATE TABLE IF NOT EXISTS public."PaymentStatuses" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_paymentstatuses_name ON public."PaymentStatuses" (lower("Name"));

-- WalletTransactionTypes
CREATE TABLE IF NOT EXISTS public."WalletTransactionTypes" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(100) NOT NULL,
  "Description" varchar(200),
  "Direction" varchar(20),
  "AffectsBalance" boolean NOT NULL DEFAULT true,
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_wallettransactiontypes_name ON public."WalletTransactionTypes" (lower("Name"));

-- Genders
CREATE TABLE IF NOT EXISTS public."Genders" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_genders_name ON public."Genders" (lower("Name"));

-- UserRoles
CREATE TABLE IF NOT EXISTS public."UserRoles" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_userroles_name ON public."UserRoles" (lower("Name"));

-- NotificationTypes
CREATE TABLE IF NOT EXISTS public."NotificationTypes" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(100) NOT NULL,
  "Description" varchar(200),
  "RequiresPushNotification" boolean NOT NULL DEFAULT false,
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_notificationtypes_name ON public."NotificationTypes" (lower("Name"));

-- CallTypes
CREATE TABLE IF NOT EXISTS public."CallTypes" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(50) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_calltypes_name ON public."CallTypes" (lower("Name"));

-- Countries
CREATE TABLE IF NOT EXISTS public."Countries" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(150) NOT NULL,
  "IsoCode" varchar(10),
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_countries_name ON public."Countries" (lower("Name"));

-- Languages
CREATE TABLE IF NOT EXISTS public."Languages" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(100) NOT NULL,
  "IsoCode" varchar(10),
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_languages_name ON public."Languages" (lower("Name"));

-- GiftCategories
CREATE TABLE IF NOT EXISTS public."GiftCategories" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" varchar(150) NOT NULL,
  "Description" varchar(200),
  "IsActive" boolean NOT NULL DEFAULT true,
  "SortOrder" smallint NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_giftcategories_name ON public."GiftCategories" (lower("Name"));

-- Add UpdatedBy foreign keys referencing Users(Id)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_userstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public."UserStatuses" ADD CONSTRAINT fk_userstatuses_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messagetypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public."MessageTypes" ADD CONSTRAINT fk_messagetypes_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messagestatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public."MessageStatuses" ADD CONSTRAINT fk_messagestatuses_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public."CallStatuses" ADD CONSTRAINT fk_callstatuses_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paymentstatuses_updatedby') THEN
	EXECUTE 'ALTER TABLE public."PaymentStatuses" ADD CONSTRAINT fk_paymentstatuses_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactiontypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactionTypes" ADD CONSTRAINT fk_wallettransactiontypes_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_genders_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Genders" ADD CONSTRAINT fk_genders_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_userroles_updatedby') THEN
	EXECUTE 'ALTER TABLE public."UserRoles" ADD CONSTRAINT fk_userroles_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notificationtypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public."NotificationTypes" ADD CONSTRAINT fk_notificationtypes_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calltypes_updatedby') THEN
	EXECUTE 'ALTER TABLE public."CallTypes" ADD CONSTRAINT fk_calltypes_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;
END;
$$;

-- Attach update triggers to all master tables
DROP TRIGGER IF EXISTS trg_userstatuses_update_timestamp ON public."UserStatuses";
CREATE TRIGGER trg_userstatuses_update_timestamp
BEFORE UPDATE ON public."UserStatuses"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messagetypes_update_timestamp ON public."MessageTypes";
CREATE TRIGGER trg_messagetypes_update_timestamp
BEFORE UPDATE ON public."MessageTypes"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messagestatuses_update_timestamp ON public."MessageStatuses";
CREATE TRIGGER trg_messagestatuses_update_timestamp
BEFORE UPDATE ON public."MessageStatuses"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_callstatuses_update_timestamp ON public."CallStatuses";
CREATE TRIGGER trg_callstatuses_update_timestamp
BEFORE UPDATE ON public."CallStatuses"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_paymentstatuses_update_timestamp ON public."PaymentStatuses";
CREATE TRIGGER trg_paymentstatuses_update_timestamp
BEFORE UPDATE ON public."PaymentStatuses"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallettransactiontypes_update_timestamp ON public."WalletTransactionTypes";
CREATE TRIGGER trg_wallettransactiontypes_update_timestamp
BEFORE UPDATE ON public."WalletTransactionTypes"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_genders_update_timestamp ON public."Genders";
CREATE TRIGGER trg_genders_update_timestamp
BEFORE UPDATE ON public."Genders"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_userroles_update_timestamp ON public."UserRoles";
CREATE TRIGGER trg_userroles_update_timestamp
BEFORE UPDATE ON public."UserRoles"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_notificationtypes_update_timestamp ON public."NotificationTypes";
CREATE TRIGGER trg_notificationtypes_update_timestamp
BEFORE UPDATE ON public."NotificationTypes"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_calltypes_update_timestamp ON public."CallTypes";
CREATE TRIGGER trg_calltypes_update_timestamp
BEFORE UPDATE ON public."CallTypes"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
