-- V1_0_1__CreateOperationTables.sql
-- PostgreSQL migration: operational tables (Users, RefreshTokens, Profiles, Wallets, WalletTransactions, Gifts, GiftTransactions, Conversations, ConversationMembers, Messages, Calls, CallParticipants, CoinPackages, Payments, Notifications)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure update_timestamp function exists
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW."UpdatedAt" = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- RefreshTokens
CREATE TABLE IF NOT EXISTS public."RefreshTokens" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "UserId" uuid NOT NULL,
  "Token" text NOT NULL,
  "ExpiresAt" timestamptz NOT NULL,
  "RevokedAt" timestamptz,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid,
  "DeviceId" varchar(200)
);
CREATE INDEX IF NOT EXISTS ix_refreshtokens_userid ON public."RefreshTokens" ("UserId");
CREATE UNIQUE INDEX IF NOT EXISTS ux_refreshtokens_token ON public."RefreshTokens" ("Token");
CREATE INDEX IF NOT EXISTS ix_refreshtokens_expiresat ON public."RefreshTokens" ("ExpiresAt");
CREATE INDEX IF NOT EXISTS ix_refreshtokens_updatedby ON public."RefreshTokens" ("UpdatedBy");

-- Profiles (one-to-one, UserId PK)
CREATE TABLE IF NOT EXISTS public."Profiles" (
  "UserId" uuid PRIMARY KEY,
  "DisplayName" varchar(200),
  "Gender" uuid,
  "DOB" date,
  "Country" uuid,
  "City" varchar(100),
  "Language" uuid,
  "Bio" text,
  "AvatarUrl" text,
  "IsVerified" boolean NOT NULL DEFAULT false,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_profiles_language ON public."Profiles" ("Language");
CREATE INDEX IF NOT EXISTS ix_profiles_updatedby ON public."Profiles" ("UpdatedBy");

-- Wallets
CREATE TABLE IF NOT EXISTS public."Wallets" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "UserId" uuid NOT NULL,
  "Balance" numeric(20,2) NOT NULL DEFAULT 0,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_wallets_userid ON public."Wallets" ("UserId");
CREATE UNIQUE INDEX IF NOT EXISTS ux_wallets_userid_unique ON public."Wallets" ("UserId");

-- WalletTransactions
CREATE TABLE IF NOT EXISTS public."WalletTransactions" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "WalletId" uuid NOT NULL,
  "Type" varchar(50) NOT NULL,
  "Amount" numeric(20,2) NOT NULL CHECK ("Amount" >= 0),
  "BalanceBefore" numeric(20,2) NOT NULL,
  "BalanceAfter" numeric(20,2) NOT NULL,
  "ReferenceType" varchar(100),
  "ReferenceId" text,
  "Description" text,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_wallettransactions_walletid ON public."WalletTransactions" ("WalletId");
CREATE INDEX IF NOT EXISTS ix_wallettransactions_reference ON public."WalletTransactions" ("ReferenceType", "ReferenceId");

-- Gifts
CREATE TABLE IF NOT EXISTS public."Gifts" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" text NOT NULL,
  "Price" numeric(20,2) NOT NULL CHECK ("Price" >= 0),
  "ImageUrl" text,
  "AnimationUrl" text,
  "IsActive" boolean NOT NULL DEFAULT TRUE,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_gifts_isactive ON public."Gifts" ("IsActive");

-- GiftTransactions
CREATE TABLE IF NOT EXISTS public."GiftTransactions" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "GiftId" uuid NOT NULL,
  "SenderUserId" uuid NOT NULL,
  "ReceiverUserId" uuid NOT NULL,
  "Coins" numeric(20,2) NOT NULL CHECK ("Coins" >= 0),
  "WalletTransactionId" uuid,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_gifttransactions_giftid ON public."GiftTransactions" ("GiftId");
CREATE INDEX IF NOT EXISTS ix_gifttransactions_sender_receiver ON public."GiftTransactions" ("SenderUserId", "ReceiverUserId");

-- Conversations
CREATE TABLE IF NOT EXISTS public."Conversations" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Type" varchar(50),
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);

-- ConversationMembers
CREATE TABLE IF NOT EXISTS public."ConversationMembers" (
  "ConversationId" uuid NOT NULL,
  "UserId" uuid NOT NULL,
  "JoinedAt" timestamptz NOT NULL DEFAULT now(),
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid,
  CONSTRAINT pk_conversationmembers PRIMARY KEY ("ConversationId", "UserId")
);
CREATE INDEX IF NOT EXISTS ix_conversationmembers_userid ON public."ConversationMembers" ("UserId");

-- Messages
CREATE TABLE IF NOT EXISTS public."Messages" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "ConversationId" uuid NOT NULL,
  "SenderUserId" uuid NOT NULL,
  "Type" varchar(50),
  "Content" text,
  "Status" smallint,
  "SentAt" timestamptz NOT NULL DEFAULT now(),
  "EditedAt" timestamptz,
  "DeletedAt" timestamptz,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_messages_conversationid ON public."Messages" ("ConversationId");
CREATE INDEX IF NOT EXISTS ix_messages_senderuserid ON public."Messages" ("SenderUserId");

-- Calls
CREATE TABLE IF NOT EXISTS public."Calls" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "ConversationId" uuid,
  "StartedAt" timestamptz,
  "EndedAt" timestamptz,
  "Duration" integer,
  "Status" smallint,
  "CoinsCharged" numeric(20,2) DEFAULT 0,
  "EndedBy" uuid,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_calls_conversationid ON public."Calls" ("ConversationId");

-- CallParticipants
CREATE TABLE IF NOT EXISTS public."CallParticipants" (
  "CallId" uuid NOT NULL,
  "UserId" uuid NOT NULL,
  "Role" varchar(50),
  "JoinedAt" timestamptz,
  "LeftAt" timestamptz,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid,
  CONSTRAINT pk_callparticipants PRIMARY KEY ("CallId", "UserId")
);
CREATE INDEX IF NOT EXISTS ix_callparticipants_userid ON public."CallParticipants" ("UserId");

-- CoinPackages
CREATE TABLE IF NOT EXISTS public."CoinPackages" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "Name" text NOT NULL,
  "Coins" integer NOT NULL DEFAULT 0,
  "BonusCoins" integer NOT NULL DEFAULT 0,
  "Price" numeric(18,4) NOT NULL DEFAULT 0,
  "Currency" varchar(10),
  "IsActive" boolean NOT NULL DEFAULT true,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_coinpackages_name ON public."CoinPackages" (lower("Name"));

-- Payments
CREATE TABLE IF NOT EXISTS public."Payments" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "UserId" uuid NOT NULL,
  "CoinPackageId" uuid NOT NULL,
  "Provider" varchar(100),
  "TransactionId" text,
  "Amount" numeric(18,4) NOT NULL DEFAULT 0,
  "Status" smallint,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_payments_userid ON public."Payments" ("UserId");
CREATE INDEX IF NOT EXISTS ix_payments_coinpackageid ON public."Payments" ("CoinPackageId");

-- Notifications
CREATE TABLE IF NOT EXISTS public."Notifications" (
  "Id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "UserId" uuid NOT NULL,
  "Title" text,
  "Body" text,
  "Type" varchar(50),
  "IsRead" boolean NOT NULL DEFAULT false,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "UpdatedBy" uuid
);
CREATE INDEX IF NOT EXISTS ix_notifications_userid ON public."Notifications" ("UserId");

-- Add foreign key constraints and UpdatedBy FKs
DO $$
BEGIN
  -- RefreshTokens
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_user') THEN
	EXECUTE 'ALTER TABLE public."RefreshTokens" ADD CONSTRAINT fk_refreshtokens_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_updatedby') THEN
	EXECUTE 'ALTER TABLE public."RefreshTokens" ADD CONSTRAINT fk_refreshtokens_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- Profiles -> Users
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_user') THEN
	EXECUTE 'ALTER TABLE public."Profiles" ADD CONSTRAINT fk_profiles_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Profiles" ADD CONSTRAINT fk_profiles_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- Wallets -> Users
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_user') THEN
	EXECUTE 'ALTER TABLE public."Wallets" ADD CONSTRAINT fk_wallets_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Wallets" ADD CONSTRAINT fk_wallets_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- WalletTransactions -> Wallets
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_wallet') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactions" ADD CONSTRAINT fk_wallettransactions_wallet FOREIGN KEY ("WalletId") REFERENCES public."Wallets"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactions" ADD CONSTRAINT fk_wallettransactions_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- Gift transactions
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_gift') THEN
	EXECUTE 'ALTER TABLE public."GiftTransactions" ADD CONSTRAINT fk_gifttransactions_gift FOREIGN KEY ("GiftId") REFERENCES public."Gifts"("Id") ON DELETE RESTRICT';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_wallettx') THEN
	EXECUTE 'ALTER TABLE public."GiftTransactions" ADD CONSTRAINT fk_gifttransactions_wallettx FOREIGN KEY ("WalletTransactionId") REFERENCES public."WalletTransactions"("Id") ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_senderuser') THEN
	EXECUTE 'ALTER TABLE public."GiftTransactions" ADD CONSTRAINT fk_gifttransactions_senderuser FOREIGN KEY ("SenderUserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_receiveruser') THEN
	EXECUTE 'ALTER TABLE public."GiftTransactions" ADD CONSTRAINT fk_gifttransactions_receiveruser FOREIGN KEY ("ReceiverUserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;

  -- Conversations and members
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversationmembers_conversation') THEN
	EXECUTE 'ALTER TABLE public."ConversationMembers" ADD CONSTRAINT fk_conversationmembers_conversation FOREIGN KEY ("ConversationId") REFERENCES public."Conversations"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversationmembers_user') THEN
	EXECUTE 'ALTER TABLE public."ConversationMembers" ADD CONSTRAINT fk_conversationmembers_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;

  -- Messages
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_conversation') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD CONSTRAINT fk_messages_conversation FOREIGN KEY ("ConversationId") REFERENCES public."Conversations"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_sender') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD CONSTRAINT fk_messages_sender FOREIGN KEY ("SenderUserId") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- Calls
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_conversation') THEN
	EXECUTE 'ALTER TABLE public."Calls" ADD CONSTRAINT fk_calls_conversation FOREIGN KEY ("ConversationId") REFERENCES public."Conversations"("Id") ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_endedby') THEN
	EXECUTE 'ALTER TABLE public."Calls" ADD CONSTRAINT fk_calls_endedby FOREIGN KEY ("EndedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  -- CallParticipants
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_call') THEN
	EXECUTE 'ALTER TABLE public."CallParticipants" ADD CONSTRAINT fk_callparticipants_call FOREIGN KEY ("CallId") REFERENCES public."Calls"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_user') THEN
	EXECUTE 'ALTER TABLE public."CallParticipants" ADD CONSTRAINT fk_callparticipants_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;

  -- CoinPackages/Payments
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_user') THEN
	EXECUTE 'ALTER TABLE public."Payments" ADD CONSTRAINT fk_payments_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_coinpackage') THEN
	EXECUTE 'ALTER TABLE public."Payments" ADD CONSTRAINT fk_payments_coinpackage FOREIGN KEY ("CoinPackageId") REFERENCES public."CoinPackages"("Id") ON DELETE RESTRICT';
  END IF;

  -- Notifications
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_user') THEN
	EXECUTE 'ALTER TABLE public."Notifications" ADD CONSTRAINT fk_notifications_user FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE';
  END IF;

  -- Attach UpdatedBy FKs where missing
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Users" ADD CONSTRAINT fk_users_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Profiles" ADD CONSTRAINT fk_profiles_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Wallets" ADD CONSTRAINT fk_wallets_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactions" ADD CONSTRAINT fk_wallettransactions_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifts_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Gifts" ADD CONSTRAINT fk_gifts_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public."GiftTransactions" ADD CONSTRAINT fk_gifttransactions_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Conversations" ADD CONSTRAINT fk_conversations_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD CONSTRAINT fk_messages_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Calls" ADD CONSTRAINT fk_calls_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_updatedby') THEN
	EXECUTE 'ALTER TABLE public."CallParticipants" ADD CONSTRAINT fk_callparticipants_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_coinpackages_updatedby') THEN
	EXECUTE 'ALTER TABLE public."CoinPackages" ADD CONSTRAINT fk_coinpackages_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Payments" ADD CONSTRAINT fk_payments_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_updatedby') THEN
	EXECUTE 'ALTER TABLE public."Notifications" ADD CONSTRAINT fk_notifications_updatedby FOREIGN KEY ("UpdatedBy") REFERENCES public."Users"("Id") ON DELETE SET NULL';
  END IF;
END;
$$;

-- Additional relations (add FK columns and constraints per diagram)
DO $$
BEGIN
  -- Users -> UserStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Users' AND column_name='UserStatusId') THEN
	EXECUTE 'ALTER TABLE public."Users" ADD COLUMN "UserStatusId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_userstatus') THEN
	EXECUTE 'ALTER TABLE public."Users" ADD CONSTRAINT fk_users_userstatus FOREIGN KEY ("UserStatusId") REFERENCES public."UserStatuses"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_users_userstatusid') THEN
	EXECUTE 'CREATE INDEX ix_users_userstatusid ON public."Users" ("UserStatusId")';
  END IF;

  -- Users -> UserRoles (single role on Users)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Users' AND column_name='UserRoleId') THEN
	EXECUTE 'ALTER TABLE public."Users" ADD COLUMN "UserRoleId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_userrole') THEN
	EXECUTE 'ALTER TABLE public."Users" ADD CONSTRAINT fk_users_userrole FOREIGN KEY ("UserRoleId") REFERENCES public."UserRoles"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_users_userroleid') THEN
	EXECUTE 'CREATE INDEX ix_users_userroleid ON public."Users" ("UserRoleId")';
  END IF;

  -- Profiles -> Genders (Profiles.Gender already exists as uuid, add FK)
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Profiles' AND column_name='Gender') THEN
	IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_gender') THEN
	  EXECUTE 'ALTER TABLE public."Profiles" ADD CONSTRAINT fk_profiles_gender FOREIGN KEY ("Gender") REFERENCES public."Genders"("Id") ON DELETE SET NULL';
	END IF;
  END IF;

  -- Messages -> MessageTypes and MessageStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Messages' AND column_name='MessageTypeId') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD COLUMN "MessageTypeId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Messages' AND column_name='MessageStatusId') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD COLUMN "MessageStatusId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_messagetype') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD CONSTRAINT fk_messages_messagetype FOREIGN KEY ("MessageTypeId") REFERENCES public."MessageTypes"("Id") ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_messagestatus') THEN
	EXECUTE 'ALTER TABLE public."Messages" ADD CONSTRAINT fk_messages_messagestatus FOREIGN KEY ("MessageStatusId") REFERENCES public."MessageStatuses"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_messages_messagetypeid') THEN
	EXECUTE 'CREATE INDEX ix_messages_messagetypeid ON public."Messages" ("MessageTypeId")';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_messages_messagestatusid') THEN
	EXECUTE 'CREATE INDEX ix_messages_messagestatusid ON public."Messages" ("MessageStatusId")';
  END IF;

  -- WalletTransactions -> WalletTransactionTypes
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='WalletTransactions' AND column_name='WalletTransactionTypeId') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactions" ADD COLUMN "WalletTransactionTypeId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_type') THEN
	EXECUTE 'ALTER TABLE public."WalletTransactions" ADD CONSTRAINT fk_wallettransactions_type FOREIGN KEY ("WalletTransactionTypeId") REFERENCES public."WalletTransactionTypes"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_wallettransactions_typeid') THEN
	EXECUTE 'CREATE INDEX ix_wallettransactions_typeid ON public."WalletTransactions" ("WalletTransactionTypeId")';
  END IF;

  -- Payments -> PaymentStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Payments' AND column_name='PaymentStatusId') THEN
	EXECUTE 'ALTER TABLE public."Payments" ADD COLUMN "PaymentStatusId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_paymentstatus') THEN
	EXECUTE 'ALTER TABLE public."Payments" ADD CONSTRAINT fk_payments_paymentstatus FOREIGN KEY ("PaymentStatusId") REFERENCES public."PaymentStatuses"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_payments_paymentstatusid') THEN
	EXECUTE 'CREATE INDEX ix_payments_paymentstatusid ON public."Payments" ("PaymentStatusId")';
  END IF;

  -- Calls -> CallStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Calls' AND column_name='CallStatusId') THEN
	EXECUTE 'ALTER TABLE public."Calls" ADD COLUMN "CallStatusId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_callstatus') THEN
	EXECUTE 'ALTER TABLE public."Calls" ADD CONSTRAINT fk_calls_callstatus FOREIGN KEY ("CallStatusId") REFERENCES public."CallStatuses"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_calls_callstatusid') THEN
	EXECUTE 'CREATE INDEX ix_calls_callstatusid ON public."Calls" ("CallStatusId")';
  END IF;

  -- Notifications -> NotificationTypes
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Notifications' AND column_name='NotificationTypeId') THEN
	EXECUTE 'ALTER TABLE public."Notifications" ADD COLUMN "NotificationTypeId" uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_notificationtype') THEN
	EXECUTE 'ALTER TABLE public."Notifications" ADD CONSTRAINT fk_notifications_notificationtype FOREIGN KEY ("NotificationTypeId") REFERENCES public."NotificationTypes"("Id") ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_notifications_notificationtypeid') THEN
	EXECUTE 'CREATE INDEX ix_notifications_notificationtypeid ON public."Notifications" ("NotificationTypeId")';
  END IF;

END;
$$;

-- Attach update triggers to tables created above
DROP TRIGGER IF EXISTS trg_users_update_timestamp ON public."Users";
CREATE TRIGGER trg_users_update_timestamp
BEFORE UPDATE ON public."Users"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_refreshtokens_update_timestamp ON public."RefreshTokens";
CREATE TRIGGER trg_refreshtokens_update_timestamp
BEFORE UPDATE ON public."RefreshTokens"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_profiles_update_timestamp ON public."Profiles";
CREATE TRIGGER trg_profiles_update_timestamp
BEFORE UPDATE ON public."Profiles"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallets_update_timestamp ON public."Wallets";
CREATE TRIGGER trg_wallets_update_timestamp
BEFORE UPDATE ON public."Wallets"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallettransactions_update_timestamp ON public."WalletTransactions";
CREATE TRIGGER trg_wallettransactions_update_timestamp
BEFORE UPDATE ON public."WalletTransactions"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_gifts_update_timestamp ON public."Gifts";
CREATE TRIGGER trg_gifts_update_timestamp
BEFORE UPDATE ON public."Gifts"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_gifttransactions_update_timestamp ON public."GiftTransactions";
CREATE TRIGGER trg_gifttransactions_update_timestamp
BEFORE UPDATE ON public."GiftTransactions"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_conversations_update_timestamp ON public."Conversations";
CREATE TRIGGER trg_conversations_update_timestamp
BEFORE UPDATE ON public."Conversations"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_conversationmembers_update_timestamp ON public."ConversationMembers";
CREATE TRIGGER trg_conversationmembers_update_timestamp
BEFORE UPDATE ON public."ConversationMembers"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messages_update_timestamp ON public."Messages";
CREATE TRIGGER trg_messages_update_timestamp
BEFORE UPDATE ON public."Messages"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_calls_update_timestamp ON public."Calls";
CREATE TRIGGER trg_calls_update_timestamp
BEFORE UPDATE ON public."Calls"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_callparticipants_update_timestamp ON public."CallParticipants";
CREATE TRIGGER trg_callparticipants_update_timestamp
BEFORE UPDATE ON public."CallParticipants"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_coinpackages_update_timestamp ON public."CoinPackages";
CREATE TRIGGER trg_coinpackages_update_timestamp
BEFORE UPDATE ON public."CoinPackages"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_payments_update_timestamp ON public."Payments";
CREATE TRIGGER trg_payments_update_timestamp
BEFORE UPDATE ON public."Payments"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_notifications_update_timestamp ON public."Notifications";
CREATE TRIGGER trg_notifications_update_timestamp
BEFORE UPDATE ON public."Notifications"
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
