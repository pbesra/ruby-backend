-- V1_0_1__CreateOperationTables.sql
-- PostgreSQL migration: operational tables (Users, RefreshTokens, Profiles, Wallets, WalletTransactions, Gifts, GiftTransactions, Conversations, ConversationMembers, Messages, Calls, CallParticipants, CoinPackages, Payments, Notifications)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure update_timestamp function exists
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updatedat = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- RefreshTokens
CREATE TABLE IF NOT EXISTS public.refreshtokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  deviceid uuid,
  token text NOT NULL,
  expiresat timestamptz NOT NULL,
  revokedat timestamptz,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_refreshtokens_userid ON public.refreshtokens (userid);
CREATE INDEX IF NOT EXISTS ix_refreshtokens_deviceid ON public.refreshtokens (deviceid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_refreshtokens_token ON public.refreshtokens (token);
CREATE INDEX IF NOT EXISTS ix_refreshtokens_expiresat ON public.refreshtokens (expiresat);
CREATE INDEX IF NOT EXISTS ix_refreshtokens_updatedby ON public.refreshtokens (updatedby);

-- UserAuthentications
CREATE TABLE IF NOT EXISTS public.userauthentications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  provider varchar(100) NOT NULL,
  provideruserid text NOT NULL,
  createdat timestamptz NOT NULL DEFAULT now(),
  lastloginat timestamptz
);
CREATE INDEX IF NOT EXISTS ix_userauthentications_userid ON public.userauthentications (userid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_userauthentications_provider_provideruserid ON public.userauthentications (provider, provideruserid);
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_userauthentications_user') THEN
	EXECUTE 'ALTER TABLE public.userauthentications ADD CONSTRAINT fk_userauthentications_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
END;
$$;

-- Profiles (one-to-one, UserId PK)
CREATE TABLE IF NOT EXISTS public.profiles (
  userid uuid PRIMARY KEY,
  firstname varchar(100),
  lastname varchar(100),
  displayname varchar(200),
  gender uuid,
  dob date,
  country uuid,
  city varchar(100),
  language uuid,
  bio text,
  avatarurl text,
  isverified boolean NOT NULL DEFAULT false,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_profiles_language ON public.profiles (language);
CREATE INDEX IF NOT EXISTS ix_profiles_updatedby ON public.profiles (updatedby);

-- Wallets
CREATE TABLE IF NOT EXISTS public.wallets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  balance numeric(20,2) NOT NULL DEFAULT 0,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_wallets_userid ON public.wallets (userid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_wallets_userid_unique ON public.wallets (userid);

-- WalletTransactions
CREATE TABLE IF NOT EXISTS public.wallettransactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  walletid uuid NOT NULL,
  type varchar(50) NOT NULL,
  amount numeric(20,2) NOT NULL CHECK (amount >= 0),
  balancebefore numeric(20,2) NOT NULL,
  balanceafter numeric(20,2) NOT NULL,
  referencetype varchar(100),
  referenceid text,
  description text,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_wallettransactions_walletid ON public.wallettransactions (walletid);
CREATE INDEX IF NOT EXISTS ix_wallettransactions_reference ON public.wallettransactions (referencetype, referenceid);

-- Gifts
CREATE TABLE IF NOT EXISTS public.gifts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric(20,2) NOT NULL CHECK (price >= 0),
  imageurl text,
  animationurl text,
  isactive boolean NOT NULL DEFAULT TRUE,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_gifts_isactive ON public.gifts (isactive);

-- GiftTransactions
CREATE TABLE IF NOT EXISTS public.gifttransactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  giftid uuid NOT NULL,
  senderuserid uuid NOT NULL,
  receiveruserid uuid NOT NULL,
  coins numeric(20,2) NOT NULL CHECK (coins >= 0),
  wallettransactionid uuid,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_gifttransactions_giftid ON public.gifttransactions (giftid);
CREATE INDEX IF NOT EXISTS ix_gifttransactions_sender_receiver ON public.gifttransactions (senderuserid, receiveruserid);

-- Conversations
CREATE TABLE IF NOT EXISTS public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type varchar(50),
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);

-- ConversationMembers
CREATE TABLE IF NOT EXISTS public.conversationmembers (
  conversationid uuid NOT NULL,
  userid uuid NOT NULL,
  joinedat timestamptz NOT NULL DEFAULT now(),
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid,
  CONSTRAINT pk_conversationmembers PRIMARY KEY (conversationid, userid)
);
CREATE INDEX IF NOT EXISTS ix_conversationmembers_userid ON public.conversationmembers (userid);

-- Messages
CREATE TABLE IF NOT EXISTS public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversationid uuid NOT NULL,
  senderuserid uuid NOT NULL,
  type varchar(50),
  content text,
  status smallint,
  sentat timestamptz NOT NULL DEFAULT now(),
  editedat timestamptz,
  deletedat timestamptz,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_messages_conversationid ON public.messages (conversationid);
CREATE INDEX IF NOT EXISTS ix_messages_senderuserid ON public.messages (senderuserid);

-- Calls
CREATE TABLE IF NOT EXISTS public.calls (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversationid uuid,
  startedat timestamptz,
  endedat timestamptz,
  duration integer,
  status smallint,
  coinscharged numeric(20,2) DEFAULT 0,
  endedby uuid,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_calls_conversationid ON public.calls (conversationid);

-- CallParticipants
CREATE TABLE IF NOT EXISTS public.callparticipants (
  callid uuid NOT NULL,
  userid uuid NOT NULL,
  role varchar(50),
  joinedat timestamptz,
  leftat timestamptz,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid,
  CONSTRAINT pk_callparticipants PRIMARY KEY (callid, userid)
);
CREATE INDEX IF NOT EXISTS ix_callparticipants_userid ON public.callparticipants (userid);

-- CoinPackages
CREATE TABLE IF NOT EXISTS public.coinpackages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  coins integer NOT NULL DEFAULT 0,
  bonuscoins integer NOT NULL DEFAULT 0,
  price numeric(18,4) NOT NULL DEFAULT 0,
  currency varchar(10),
  isactive boolean NOT NULL DEFAULT true,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_coinpackages_name ON public.coinpackages (lower(name));

-- Payments
CREATE TABLE IF NOT EXISTS public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  coinpackageid uuid NOT NULL,
  provider varchar(100),
  transactionid text,
  amount numeric(18,4) NOT NULL DEFAULT 0,
  status smallint,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_payments_userid ON public.payments (userid);
CREATE INDEX IF NOT EXISTS ix_payments_coinpackageid ON public.payments (coinpackageid);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  userid uuid NOT NULL,
  title text,
  body text,
  type varchar(50),
  isread boolean NOT NULL DEFAULT false,
  createdat timestamptz NOT NULL DEFAULT now(),
  updatedat timestamptz NOT NULL DEFAULT now(),
  updatedby uuid
);
CREATE INDEX IF NOT EXISTS ix_notifications_userid ON public.notifications (userid);

-- Add foreign key constraints and UpdatedBy FKs
DO $$
BEGIN
  -- RefreshTokens
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_user') THEN
	EXECUTE 'ALTER TABLE public.refreshtokens ADD CONSTRAINT fk_refreshtokens_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_updatedby') THEN
	EXECUTE 'ALTER TABLE public.refreshtokens ADD CONSTRAINT fk_refreshtokens_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_device') THEN
	-- Only add FK if the referenced table exists to avoid migration failure
	IF EXISTS (
	  SELECT 1 FROM pg_class c
	  JOIN pg_namespace n ON n.oid = c.relnamespace
	  WHERE n.nspname = 'public' AND c.relname = 'Device'
	) THEN
	  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_refreshtokens_device') THEN
		EXECUTE 'ALTER TABLE public.refreshtokens ADD CONSTRAINT fk_refreshtokens_device FOREIGN KEY (deviceid) REFERENCES public.device(id) ON DELETE SET NULL';
	  END IF;
	END IF;
	END IF;

  -- Profiles -> Users
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_user') THEN
	EXECUTE 'ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_updatedby') THEN
	EXECUTE 'ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  -- Wallets -> Users
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_user') THEN
	EXECUTE 'ALTER TABLE public.wallets ADD CONSTRAINT fk_wallets_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_updatedby') THEN
	EXECUTE 'ALTER TABLE public.wallets ADD CONSTRAINT fk_wallets_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  -- WalletTransactions -> Wallets
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_wallet') THEN
	EXECUTE 'ALTER TABLE public.wallettransactions ADD CONSTRAINT fk_wallettransactions_wallet FOREIGN KEY (walletid) REFERENCES public.wallets(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public.wallettransactions ADD CONSTRAINT fk_wallettransactions_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  -- Gift transactions
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_gift') THEN
	EXECUTE 'ALTER TABLE public.gifttransactions ADD CONSTRAINT fk_gifttransactions_gift FOREIGN KEY (giftid) REFERENCES public.gifts(id) ON DELETE RESTRICT';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_wallettx') THEN
	EXECUTE 'ALTER TABLE public.gifttransactions ADD CONSTRAINT fk_gifttransactions_wallettx FOREIGN KEY (wallettransactionid) REFERENCES public.wallettransactions(id) ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_senderuser') THEN
	EXECUTE 'ALTER TABLE public.gifttransactions ADD CONSTRAINT fk_gifttransactions_senderuser FOREIGN KEY (senderuserid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_receiveruser') THEN
	EXECUTE 'ALTER TABLE public.gifttransactions ADD CONSTRAINT fk_gifttransactions_receiveruser FOREIGN KEY (receiveruserid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;

  -- Conversations and members
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversationmembers_conversation') THEN
	EXECUTE 'ALTER TABLE public.conversationmembers ADD CONSTRAINT fk_conversationmembers_conversation FOREIGN KEY (conversationid) REFERENCES public.conversations(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversationmembers_user') THEN
	EXECUTE 'ALTER TABLE public.conversationmembers ADD CONSTRAINT fk_conversationmembers_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;

  -- Messages
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_conversation') THEN
	EXECUTE 'ALTER TABLE public.messages ADD CONSTRAINT fk_messages_conversation FOREIGN KEY (conversationid) REFERENCES public.conversations(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_sender') THEN
	EXECUTE 'ALTER TABLE public.messages ADD CONSTRAINT fk_messages_sender FOREIGN KEY (senderuserid) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  -- Calls
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_conversation') THEN
	EXECUTE 'ALTER TABLE public.calls ADD CONSTRAINT fk_calls_conversation FOREIGN KEY (conversationid) REFERENCES public.conversations(id) ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_endedby') THEN
	EXECUTE 'ALTER TABLE public.calls ADD CONSTRAINT fk_calls_endedby FOREIGN KEY (endedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  -- CallParticipants
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_call') THEN
	EXECUTE 'ALTER TABLE public.callparticipants ADD CONSTRAINT fk_callparticipants_call FOREIGN KEY (callid) REFERENCES public.calls(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_user') THEN
	EXECUTE 'ALTER TABLE public.callparticipants ADD CONSTRAINT fk_callparticipants_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;

  -- CoinPackages/Payments
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_user') THEN
	EXECUTE 'ALTER TABLE public.payments ADD CONSTRAINT fk_payments_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_coinpackage') THEN
	EXECUTE 'ALTER TABLE public.payments ADD CONSTRAINT fk_payments_coinpackage FOREIGN KEY (coinpackageid) REFERENCES public.coinpackages(id) ON DELETE RESTRICT';
  END IF;

  -- Notifications
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_user') THEN
	EXECUTE 'ALTER TABLE public.notifications ADD CONSTRAINT fk_notifications_user FOREIGN KEY (userid) REFERENCES public.Users(id) ON DELETE CASCADE';
  END IF;

  -- Attach UpdatedBy FKs where missing
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_updatedby') THEN
	EXECUTE 'ALTER TABLE public.Users ADD CONSTRAINT fk_users_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_updatedby') THEN
	EXECUTE 'ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallets_updatedby') THEN
	EXECUTE 'ALTER TABLE public.wallets ADD CONSTRAINT fk_wallets_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public.wallettransactions ADD CONSTRAINT fk_wallettransactions_updatedby FOREIGN KEY (updatedby) REFERENCES public.users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifts_updatedby') THEN
	EXECUTE 'ALTER TABLE public.gifts ADD CONSTRAINT fk_gifts_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_gifttransactions_updatedby') THEN
	EXECUTE 'ALTER TABLE public.gifttransactions ADD CONSTRAINT fk_gifttransactions_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_updatedby') THEN
	EXECUTE 'ALTER TABLE public.conversations ADD CONSTRAINT fk_conversations_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_updatedby') THEN
	EXECUTE 'ALTER TABLE public.messages ADD CONSTRAINT fk_messages_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_updatedby') THEN
	EXECUTE 'ALTER TABLE public.calls ADD CONSTRAINT fk_calls_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_callparticipants_updatedby') THEN
	EXECUTE 'ALTER TABLE public.callparticipants ADD CONSTRAINT fk_callparticipants_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_coinpackages_updatedby') THEN
	EXECUTE 'ALTER TABLE public.coinpackages ADD CONSTRAINT fk_coinpackages_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_updatedby') THEN
	EXECUTE 'ALTER TABLE public.payments ADD CONSTRAINT fk_payments_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_updatedby') THEN
	EXECUTE 'ALTER TABLE public.notifications ADD CONSTRAINT fk_notifications_updatedby FOREIGN KEY (updatedby) REFERENCES public.Users(id) ON DELETE SET NULL';
  END IF;
END;
$$;

-- Additional relations (add FK columns and constraints per diagram)
DO $$
BEGIN
  -- Users -> UserStatuses
IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='userstatusid') THEN
	EXECUTE 'ALTER TABLE public.Users ADD COLUMN userstatusid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_userstatus') THEN
	EXECUTE 'ALTER TABLE public.Users ADD CONSTRAINT fk_users_userstatus FOREIGN KEY (userstatusid) REFERENCES public.userstatuses(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_users_userstatusid') THEN
		EXECUTE 'CREATE INDEX ix_users_userstatusid ON public.Users (userstatusid)';
  END IF;

  -- Users -> UserRoles (single role on Users)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='userroleid') THEN
	EXECUTE 'ALTER TABLE public.Users ADD COLUMN userroleid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_userrole') THEN
	EXECUTE 'ALTER TABLE public.Users ADD CONSTRAINT fk_users_userrole FOREIGN KEY (userroleid) REFERENCES public.userroles(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_users_userroleid') THEN
		EXECUTE 'CREATE INDEX ix_users_userroleid ON public.Users (userroleid)';
  END IF;

  -- Profiles -> Genders (Profiles.Gender already exists as uuid, add FK)
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='gender') THEN
	IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_gender') THEN
	  EXECUTE 'ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_gender FOREIGN KEY (gender) REFERENCES public.genders(id) ON DELETE SET NULL';
	END IF;
  END IF;

  -- Messages -> MessageTypes and MessageStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Messages' AND column_name='MessageTypeId') THEN
	EXECUTE 'ALTER TABLE public.messages ADD COLUMN messagetypeid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Messages' AND column_name='MessageStatusId') THEN
	EXECUTE 'ALTER TABLE public.messages ADD COLUMN messagestatusid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_messagetype') THEN
	EXECUTE 'ALTER TABLE public.messages ADD CONSTRAINT fk_messages_messagetype FOREIGN KEY (messagetypeid) REFERENCES public.messagetypes(id) ON DELETE SET NULL';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_messagestatus') THEN
	EXECUTE 'ALTER TABLE public.messages ADD CONSTRAINT fk_messages_messagestatus FOREIGN KEY (messagestatusid) REFERENCES public.messagestatuses(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_messages_messagetypeid') THEN
	EXECUTE 'CREATE INDEX ix_messages_messagetypeid ON public.messages (messagetypeid)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_messages_messagestatusid') THEN
	EXECUTE 'CREATE INDEX ix_messages_messagestatusid ON public.messages (messagestatusid)';
  END IF;

  -- WalletTransactions -> WalletTransactionTypes
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='WalletTransactions' AND column_name='WalletTransactionTypeId') THEN
	EXECUTE 'ALTER TABLE public.wallettransactions ADD COLUMN wallettransactiontypeid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_wallettransactions_type') THEN
	EXECUTE 'ALTER TABLE public.wallettransactions ADD CONSTRAINT fk_wallettransactions_type FOREIGN KEY (wallettransactiontypeid) REFERENCES public.wallettransactiontypes(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_wallettransactions_typeid') THEN
	EXECUTE 'CREATE INDEX ix_wallettransactions_typeid ON public.wallettransactions (wallettransactiontypeid)';
  END IF;

  -- Payments -> PaymentStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Payments' AND column_name='PaymentStatusId') THEN
	EXECUTE 'ALTER TABLE public.payments ADD COLUMN paymentstatusid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payments_paymentstatus') THEN
	EXECUTE 'ALTER TABLE public.payments ADD CONSTRAINT fk_payments_paymentstatus FOREIGN KEY (paymentstatusid) REFERENCES public.paymentstatuses(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_payments_paymentstatusid') THEN
	EXECUTE 'CREATE INDEX ix_payments_paymentstatusid ON public.payments (paymentstatusid)';
  END IF;

  -- Calls -> CallStatuses
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Calls' AND column_name='CallStatusId') THEN
	EXECUTE 'ALTER TABLE public.calls ADD COLUMN callstatusid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_calls_callstatus') THEN
	EXECUTE 'ALTER TABLE public.calls ADD CONSTRAINT fk_calls_callstatus FOREIGN KEY (callstatusid) REFERENCES public.callstatuses(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_calls_callstatusid') THEN
	EXECUTE 'CREATE INDEX ix_calls_callstatusid ON public.calls (callstatusid)';
  END IF;

  -- Notifications -> NotificationTypes
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='Notifications' AND column_name='NotificationTypeId') THEN
	EXECUTE 'ALTER TABLE public.notifications ADD COLUMN notificationtypeid uuid';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_notificationtype') THEN
	EXECUTE 'ALTER TABLE public.notifications ADD CONSTRAINT fk_notifications_notificationtype FOREIGN KEY (notificationtypeid) REFERENCES public.notificationtypes(id) ON DELETE SET NULL';
  END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'ix_notifications_notificationtypeid') THEN
	EXECUTE 'CREATE INDEX ix_notifications_notificationtypeid ON public.notifications (notificationtypeid)';
  END IF;

END;
$$;

-- Attach update triggers to tables created above
DROP TRIGGER IF EXISTS trg_users_update_timestamp ON public.users;
CREATE TRIGGER trg_users_update_timestamp
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_refreshtokens_update_timestamp ON public.refreshtokens;
CREATE TRIGGER trg_refreshtokens_update_timestamp
BEFORE UPDATE ON public.refreshtokens
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_profiles_update_timestamp ON public.profiles;
CREATE TRIGGER trg_profiles_update_timestamp
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallets_update_timestamp ON public.wallets;
CREATE TRIGGER trg_wallets_update_timestamp
BEFORE UPDATE ON public.wallets
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_wallettransactions_update_timestamp ON public.wallettransactions;
CREATE TRIGGER trg_wallettransactions_update_timestamp
BEFORE UPDATE ON public.wallettransactions
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_gifts_update_timestamp ON public.gifts;
CREATE TRIGGER trg_gifts_update_timestamp
BEFORE UPDATE ON public.gifts
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_gifttransactions_update_timestamp ON public.gifttransactions;
CREATE TRIGGER trg_gifttransactions_update_timestamp
BEFORE UPDATE ON public.gifttransactions
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_conversations_update_timestamp ON public.conversations;
CREATE TRIGGER trg_conversations_update_timestamp
BEFORE UPDATE ON public.conversations
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_conversationmembers_update_timestamp ON public.conversationmembers;
CREATE TRIGGER trg_conversationmembers_update_timestamp
BEFORE UPDATE ON public.conversationmembers
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_messages_update_timestamp ON public.messages;
CREATE TRIGGER trg_messages_update_timestamp
BEFORE UPDATE ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_calls_update_timestamp ON public.calls;
CREATE TRIGGER trg_calls_update_timestamp
BEFORE UPDATE ON public.calls
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_callparticipants_update_timestamp ON public.callparticipants;
CREATE TRIGGER trg_callparticipants_update_timestamp
BEFORE UPDATE ON public.callparticipants
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_coinpackages_update_timestamp ON public.coinpackages;
CREATE TRIGGER trg_coinpackages_update_timestamp
BEFORE UPDATE ON public.coinpackages
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_payments_update_timestamp ON public.payments;
CREATE TRIGGER trg_payments_update_timestamp
BEFORE UPDATE ON public.payments
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS trg_notifications_update_timestamp ON public.notifications;
CREATE TRIGGER trg_notifications_update_timestamp
BEFORE UPDATE ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.update_timestamp();
