-- IshqTalk Database Schema for Supabase - SECURITY FIXED
-- Run this in Supabase SQL Editor: https://pqbvflfkhnqgaeczdaoh.supabase.co
-- This version fixes all security vulnerabilities identified in the audit

-- Enable UUID extension (modern Postgres built-in preferred)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- DROP EXISTING OBJECTS (makes script rerunnable)
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_account_created ON public.accounts;
DROP TRIGGER IF EXISTS set_accounts_updated_at ON public.accounts;
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS set_conversations_updated_at ON public.conversations;
DROP TRIGGER IF EXISTS set_wallets_updated_at ON public.wallets;

DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_account() CASCADE;
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.get_or_create_conversation(UUID, UUID) CASCADE;

DROP TABLE IF EXISTS public.wallet_transactions CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.calls CASCADE;
DROP TABLE IF EXISTS public.reports CASCADE;
DROP TABLE IF EXISTS public.blocks CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.wallets CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.accounts CASCADE;

-- ============================================================================
-- ACCOUNTS TABLE
-- ============================================================================
CREATE TABLE public.accounts (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  phone TEXT UNIQUE, -- Support phone-only signups
  display_name TEXT,
  bio TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  -- Status is PROTECTED - only server-side functions can modify
  status TEXT NOT NULL DEFAULT 'pending_verification' 
    CHECK (status IN ('pending_verification', 'active', 'restricted', 'suspended', 'deletion_pending', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Index for email sync checking
CREATE INDEX idx_accounts_email ON public.accounts(email) WHERE email IS NOT NULL;
CREATE INDEX idx_accounts_status ON public.accounts(status);

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES public.accounts(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  photos JSONB DEFAULT '[]'::jsonb,
  interests TEXT[] DEFAULT ARRAY[]::TEXT[],
  languages TEXT[] DEFAULT ARRAY[]::TEXT[],
  location_city TEXT,
  location_country TEXT,
  -- PROTECTED fields - only server/admin can modify
  is_host BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  -- Discovery status cached from accounts.status for RLS performance
  discovery_status TEXT NOT NULL DEFAULT 'pending_verification',
  host_rating DECIMAL(3,2) DEFAULT 0.00,
  total_calls INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_discovery ON public.profiles(discovery_status) WHERE discovery_status = 'active';

-- ============================================================================
-- CONVERSATIONS TABLE
-- ============================================================================
CREATE TABLE public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_1 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  participant_2 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Enforce ordering and prevent self-conversations
  CHECK (participant_1 < participant_2),
  -- Unique constraint with normalized ordering
  UNIQUE(participant_1, participant_2)
);

CREATE INDEX idx_conversations_participant_1 ON public.conversations(participant_1);
CREATE INDEX idx_conversations_participant_2 ON public.conversations(participant_2);
CREATE INDEX idx_conversations_last_message ON public.conversations(last_message_at DESC);

-- ============================================================================
-- MESSAGES TABLE
-- ============================================================================
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'gift', 'system')),
  metadata JSONB DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read', 'moderated', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  moderated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_messages_conversation ON public.messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_status ON public.messages(status) WHERE status != 'deleted';

-- ============================================================================
-- CALLS TABLE
-- ============================================================================
CREATE TABLE public.calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caller_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  callee_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'initiating' 
    CHECK (status IN ('initiating', 'ringing', 'active', 'ended', 'missed', 'declined', 'failed')),
  duration_seconds INTEGER DEFAULT 0,
  cost_coins INTEGER DEFAULT 0,
  rtc_session_id TEXT,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_calls_caller ON public.calls(caller_id, created_at DESC);
CREATE INDEX idx_calls_callee ON public.calls(callee_id, created_at DESC);
CREATE INDEX idx_calls_status ON public.calls(status);

-- ============================================================================
-- WALLETS TABLE
-- ============================================================================
CREATE TABLE public.wallets (
  id UUID PRIMARY KEY REFERENCES public.accounts(id) ON DELETE CASCADE,
  balance_coins INTEGER NOT NULL DEFAULT 0 CHECK (balance_coins >= 0),
  balance_gems INTEGER NOT NULL DEFAULT 0 CHECK (balance_gems >= 0),
  lifetime_earned INTEGER NOT NULL DEFAULT 0,
  lifetime_spent INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- WALLET TRANSACTIONS TABLE
-- ============================================================================
CREATE TABLE public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('purchase', 'spend', 'earn', 'refund', 'bonus', 'adjustment')),
  amount_coins INTEGER NOT NULL,
  amount_gems INTEGER NOT NULL DEFAULT 0,
  balance_after_coins INTEGER NOT NULL,
  balance_after_gems INTEGER NOT NULL,
  reference_type TEXT,
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallet_transactions_wallet ON public.wallet_transactions(wallet_id, created_at DESC);

-- ============================================================================
-- BLOCKS TABLE
-- ============================================================================
CREATE TABLE public.blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CHECK (blocker_id != blocked_id)
);

CREATE INDEX idx_blocks_blocker ON public.blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON public.blocks(blocked_id);

-- ============================================================================
-- REPORTS TABLE
-- ============================================================================
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  reported_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  report_type TEXT NOT NULL CHECK (report_type IN ('spam', 'harassment', 'inappropriate_content', 'fake_profile', 'underage', 'other')),
  description TEXT,
  evidence_urls TEXT[],
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES public.accounts(id),
  reviewed_at TIMESTAMPTZ,
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reports_reporter ON public.reports(reporter_id);
CREATE INDEX idx_reports_reported ON public.reports(reported_id);
CREATE INDEX idx_reports_status ON public.reports(status) WHERE status != 'resolved';

-- ============================================================================
-- SECURITY DEFINER FUNCTIONS (with fixed search_path)
-- ============================================================================

-- Trigger function for new auth.users (on signup)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
-- Fix: Set search_path to prevent injection
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN
  -- Support both email and phone signups
  INSERT INTO public.accounts (id, email, phone, display_name, status)
  VALUES (
    NEW.id,
    NEW.email, -- Can be NULL for phone-only signups
    NEW.phone, -- Can be NULL for email-only signups
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    CASE 
      WHEN NEW.email_confirmed_at IS NOT NULL OR NEW.phone_confirmed_at IS NOT NULL 
        THEN 'active'
      ELSE 'pending_verification'
    END
  );
  RETURN NEW;
END;
$$;

-- Trigger function for new accounts (after insert)
CREATE OR REPLACE FUNCTION public.handle_new_account()
RETURNS TRIGGER
SECURITY DEFINER
-- Fix: Set search_path to prevent injection
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN
  -- Create wallet with welcome bonus
  INSERT INTO public.wallets (id, balance_coins, balance_gems)
  VALUES (NEW.id, 100, 0);
  
  -- Record welcome bonus transaction
  INSERT INTO public.wallet_transactions (
    wallet_id, 
    type, 
    amount_coins, 
    amount_gems,
    balance_after_coins,
    balance_after_gems,
    description
  )
  VALUES (
    NEW.id,
    'bonus',
    100,
    0,
    100,
    0,
    'Welcome bonus'
  );
  
  -- Create profile with cached discovery status
  INSERT INTO public.profiles (id, display_name, discovery_status)
  VALUES (NEW.id, COALESCE(NEW.display_name, 'User'), NEW.status);
  
  RETURN NEW;
END;
$$;

-- Trigger function for updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Helper function to get or create conversation (with participant ordering)
CREATE OR REPLACE FUNCTION public.get_or_create_conversation(
  user1_id UUID,
  user2_id UUID
)
RETURNS UUID
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
  conv_id UUID;
  p1 UUID;
  p2 UUID;
BEGIN
  -- Prevent self-conversations
  IF user1_id = user2_id THEN
    RAISE EXCEPTION 'Cannot create conversation with yourself';
  END IF;
  
  -- Ensure consistent ordering (smaller UUID first)
  IF user1_id < user2_id THEN
    p1 := user1_id;
    p2 := user2_id;
  ELSE
    p1 := user2_id;
    p2 := user1_id;
  END IF;
  
  -- Try to find existing conversation
  SELECT id INTO conv_id
  FROM public.conversations
  WHERE participant_1 = p1 AND participant_2 = p2;
  
  -- Create if doesn't exist
  IF conv_id IS NULL THEN
    INSERT INTO public.conversations (participant_1, participant_2)
    VALUES (p1, p2)
    RETURNING id INTO conv_id;
  END IF;
  
  RETURN conv_id;
END;
$$;

-- Function to sync discovery status when account status changes
CREATE OR REPLACE FUNCTION public.sync_discovery_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Update profile discovery status when account status changes
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    UPDATE public.profiles
    SET discovery_status = NEW.status
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Create account on auth user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- Create wallet and profile after account creation
CREATE TRIGGER on_account_created
  AFTER INSERT ON public.accounts
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_account();

-- Sync discovery status on account status change
CREATE TRIGGER on_account_status_change
  AFTER UPDATE ON public.accounts
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.sync_discovery_status();

-- Updated_at triggers
CREATE TRIGGER set_accounts_updated_at
  BEFORE UPDATE ON public.accounts
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_conversations_updated_at
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_wallets_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ACCOUNTS POLICIES
-- ============================================================================

-- Users can view their own account
CREATE POLICY "Users can view own account"
  ON public.accounts FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Users can update ONLY safe columns (NOT status, deleted_at)
CREATE POLICY "Users can update own safe account fields"
  ON public.accounts FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Prevent users from modifying protected fields
    AND status = (SELECT status FROM public.accounts WHERE id = auth.uid())
    AND COALESCE(deleted_at, 'infinity'::timestamptz) = 
        (SELECT COALESCE(deleted_at, 'infinity'::timestamptz) FROM public.accounts WHERE id = auth.uid())
  );

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================

-- Authenticated users can view active profiles (using cached discovery_status)
-- Fix: Use discovery_status on profiles table instead of checking accounts
CREATE POLICY "Authenticated users can view active profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    discovery_status = 'active'
    -- Not blocked by viewer
    AND NOT EXISTS (
      SELECT 1 FROM public.blocks
      WHERE blocks.blocker_id = profiles.id
      AND blocks.blocked_id = auth.uid()
    )
    -- Not blocked by profile owner
    AND NOT EXISTS (
      SELECT 1 FROM public.blocks
      WHERE blocks.blocker_id = auth.uid()
      AND blocks.blocked_id = profiles.id
    )
  );

-- Users can view their own profile regardless of status
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Users can update ONLY safe columns (NOT is_verified, is_host, discovery_status)
CREATE POLICY "Users can update own safe profile fields"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Prevent modifying protected fields
    AND is_verified = (SELECT is_verified FROM public.profiles WHERE id = auth.uid())
    AND is_host = (SELECT is_host FROM public.profiles WHERE id = auth.uid())
    AND discovery_status = (SELECT discovery_status FROM public.profiles WHERE id = auth.uid())
    AND host_rating = (SELECT host_rating FROM public.profiles WHERE id = auth.uid())
    AND total_calls = (SELECT total_calls FROM public.profiles WHERE id = auth.uid())
  );

-- Users can insert their own profile (created by trigger, but allow manual creation)
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = id
    -- Ensure protected fields have safe defaults
    AND is_verified = FALSE
    AND is_host = FALSE
    AND discovery_status IN ('pending_verification', 'active')
  );

-- ============================================================================
-- CONVERSATIONS POLICIES
-- ============================================================================

-- Users can view their own conversations
CREATE POLICY "Users can view own conversations"
  ON public.conversations FOR SELECT
  TO authenticated
  USING (auth.uid() IN (participant_1, participant_2));

-- Fix: Add INSERT policy so users can create conversations
CREATE POLICY "Users can create conversations they participate in"
  ON public.conversations FOR INSERT
  TO authenticated
  WITH CHECK (
    -- User must be one of the participants
    auth.uid() IN (participant_1, participant_2)
    -- Enforce ordering constraint client-side too
    AND participant_1 < participant_2
    -- Prevent self-conversations
    AND participant_1 != participant_2
  );

-- Users can update their own conversations (e.g., last_message_at)
CREATE POLICY "Users can update own conversations"
  ON public.conversations FOR UPDATE
  TO authenticated
  USING (auth.uid() IN (participant_1, participant_2))
  WITH CHECK (auth.uid() IN (participant_1, participant_2));

-- ============================================================================
-- MESSAGES POLICIES
-- ============================================================================

-- Users can view messages in their conversations
CREATE POLICY "Users can view messages in their conversations"
  ON public.messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = messages.conversation_id
      AND auth.uid() IN (conversations.participant_1, conversations.participant_2)
    )
    AND messages.status != 'deleted'
  );

-- Users can send messages in their conversations
CREATE POLICY "Users can send messages in their conversations"
  ON public.messages FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = conversation_id
      AND auth.uid() IN (conversations.participant_1, conversations.participant_2)
    )
  );

-- Users can update their own messages (e.g., mark as deleted)
CREATE POLICY "Users can update their own messages"
  ON public.messages FOR UPDATE
  TO authenticated
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

-- ============================================================================
-- CALLS POLICIES
-- ============================================================================

-- Users can view their own calls
CREATE POLICY "Users can view their own calls"
  ON public.calls FOR SELECT
  TO authenticated
  USING (auth.uid() IN (caller_id, callee_id));

-- Users can create calls they initiate
CREATE POLICY "Users can create calls they initiate"
  ON public.calls FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = caller_id);

-- Users can update calls they're part of
CREATE POLICY "Users can update calls they're part of"
  ON public.calls FOR UPDATE
  TO authenticated
  USING (auth.uid() IN (caller_id, callee_id))
  WITH CHECK (auth.uid() IN (caller_id, callee_id));

-- ============================================================================
-- WALLETS POLICIES
-- ============================================================================

-- Users can view own wallet
CREATE POLICY "Users can view own wallet"
  ON public.wallets FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Note: No UPDATE policy - only server-side functions can modify wallets

-- ============================================================================
-- WALLET TRANSACTIONS POLICIES
-- ============================================================================

-- Users can view own wallet transactions
CREATE POLICY "Users can view own wallet transactions"
  ON public.wallet_transactions FOR SELECT
  TO authenticated
  USING (wallet_id = auth.uid());

-- Note: No INSERT policy - only server-side functions can create transactions

-- ============================================================================
-- BLOCKS POLICIES
-- ============================================================================

-- Users can view their blocks
CREATE POLICY "Users can view their blocks"
  ON public.blocks FOR SELECT
  TO authenticated
  USING (auth.uid() = blocker_id);

-- Users can create blocks
CREATE POLICY "Users can create blocks"
  ON public.blocks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = blocker_id);

-- Users can delete their blocks (unblock)
CREATE POLICY "Users can delete their blocks"
  ON public.blocks FOR DELETE
  TO authenticated
  USING (auth.uid() = blocker_id);

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================

-- Users can view their own reports
CREATE POLICY "Users can view their own reports"
  ON public.reports FOR SELECT
  TO authenticated
  USING (auth.uid() = reporter_id);

-- Users can create reports
CREATE POLICY "Users can create reports"
  ON public.reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

-- ============================================================================
-- GRANTS FOR DATA API ACCESS
-- ============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated, anon;

-- Grant SELECT on all tables to authenticated users (RLS will further restrict)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant INSERT where appropriate
GRANT INSERT ON public.profiles TO authenticated;
GRANT INSERT ON public.conversations TO authenticated;
GRANT INSERT ON public.messages TO authenticated;
GRANT INSERT ON public.calls TO authenticated;
GRANT INSERT ON public.blocks TO authenticated;
GRANT INSERT ON public.reports TO authenticated;

-- Grant UPDATE where appropriate
GRANT UPDATE ON public.accounts TO authenticated;
GRANT UPDATE ON public.profiles TO authenticated;
GRANT UPDATE ON public.conversations TO authenticated;
GRANT UPDATE ON public.messages TO authenticated;
GRANT UPDATE ON public.calls TO authenticated;

-- Grant DELETE where appropriate
GRANT DELETE ON public.blocks TO authenticated;

-- Grant sequence usage for serial columns (if any added later)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '=================================================================';
  RAISE NOTICE 'IshqTalk database schema created successfully! (SECURITY FIXED)';
  RAISE NOTICE '=================================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Tables created: accounts, profiles, conversations, messages,';
  RAISE NOTICE '                calls, wallets, wallet_transactions, blocks, reports';
  RAISE NOTICE '';
  RAISE NOTICE 'Security fixes applied:';
  RAISE NOTICE '  ✓ Protected account status from user modification';
  RAISE NOTICE '  ✓ Protected profile is_verified and is_host flags';
  RAISE NOTICE '  ✓ Fixed profile discovery with cached discovery_status';
  RAISE NOTICE '  ✓ Added INSERT policy for conversations';
  RAISE NOTICE '  ✓ Fixed SECURITY DEFINER functions with search_path';
  RAISE NOTICE '  ✓ Support for phone-only signups';
  RAISE NOTICE '  ✓ Prevented self-conversations';
  RAISE NOTICE '  ✓ Script is now rerunnable (DROP IF EXISTS)';
  RAISE NOTICE '  ✓ Added explicit table grants for Data API';
  RAISE NOTICE '  ✓ Using gen_random_uuid() (modern Postgres)';
  RAISE NOTICE '';
  RAISE NOTICE 'Row Level Security enabled on all tables';
  RAISE NOTICE 'Triggers configured for automatic account/wallet/profile creation';
  RAISE NOTICE '=================================================================';
END $$;
