-- IshqTalk Database Schema for Supabase
-- Run this in Supabase SQL Editor: https://pqbvflfkhnqgaeczdaoh.supabase.co

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- ACCOUNTS TABLE
-- ============================================================================
-- Extends Supabase auth.users with application-specific account data
CREATE TABLE IF NOT EXISTS public.accounts (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  bio TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  status TEXT NOT NULL DEFAULT 'pending_verification' 
    CHECK (status IN ('pending_verification', 'active', 'restricted', 'suspended', 'deletion_pending', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- ============================================================================
-- TRIGGERS FOR ACCOUNT CREATION
-- ============================================================================
-- Automatically create account record when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.accounts (id, email, display_name, status)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    CASE 
      WHEN NEW.email_confirmed_at IS NULL THEN 'pending_verification'
      ELSE 'active'
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
-- Public profile information visible to other users
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES public.accounts(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  photos JSONB DEFAULT '[]'::jsonb,
  interests TEXT[] DEFAULT ARRAY[]::TEXT[],
  languages TEXT[] DEFAULT ARRAY[]::TEXT[],
  location_city TEXT,
  location_country TEXT,
  is_host BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  host_rating DECIMAL(3,2) DEFAULT 0.00,
  total_calls INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- CONVERSATIONS TABLE
-- ============================================================================
-- One-to-one conversations between users
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_1 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  participant_2 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(participant_1, participant_2),
  CHECK (participant_1 < participant_2) -- Ensure consistent ordering
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_conversations_participant_1 ON public.conversations(participant_1);
CREATE INDEX IF NOT EXISTS idx_conversations_participant_2 ON public.conversations(participant_2);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_at DESC);

-- ============================================================================
-- MESSAGES TABLE
-- ============================================================================
-- Messages within conversations
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_status ON public.messages(status) WHERE status != 'deleted';

-- ============================================================================
-- CALLS TABLE
-- ============================================================================
-- Video call history and metadata
CREATE TABLE IF NOT EXISTS public.calls (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Indexes
CREATE INDEX IF NOT EXISTS idx_calls_caller ON public.calls(caller_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calls_callee ON public.calls(callee_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calls_status ON public.calls(status);

-- ============================================================================
-- WALLETS TABLE
-- ============================================================================
-- Virtual currency balances for each user
CREATE TABLE IF NOT EXISTS public.wallets (
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
-- Audit log of all wallet transactions
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('purchase', 'spend', 'earn', 'refund', 'bonus', 'adjustment')),
  amount_coins INTEGER NOT NULL,
  amount_gems INTEGER NOT NULL DEFAULT 0,
  balance_after_coins INTEGER NOT NULL,
  balance_after_gems INTEGER NOT NULL,
  reference_type TEXT, -- 'call', 'purchase', 'gift', etc.
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for transaction history
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet ON public.wallet_transactions(wallet_id, created_at DESC);

-- ============================================================================
-- BLOCKS TABLE
-- ============================================================================
-- Users blocking other users
CREATE TABLE IF NOT EXISTS public.blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CHECK (blocker_id != blocked_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_blocks_blocker ON public.blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked ON public.blocks(blocked_id);

-- ============================================================================
-- REPORTS TABLE
-- ============================================================================
-- User reports for safety/moderation
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Indexes
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported ON public.reports(reported_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status) WHERE status != 'resolved';

-- ============================================================================
-- TRIGGERS FOR WALLET AND PROFILE CREATION
-- ============================================================================
-- Automatically create wallet and profile when account is created
CREATE OR REPLACE FUNCTION public.handle_new_account()
RETURNS TRIGGER AS $$
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
  
  -- Create profile
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.display_name, 'User'));
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_account_created ON public.accounts;
CREATE TRIGGER on_account_created
  AFTER INSERT ON public.accounts
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_account();

-- ============================================================================
-- UPDATED_AT TRIGGERS
-- ============================================================================
-- Automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to all tables
DROP TRIGGER IF EXISTS set_accounts_updated_at ON public.accounts;
CREATE TRIGGER set_accounts_updated_at
  BEFORE UPDATE ON public.accounts
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_conversations_updated_at ON public.conversations;
CREATE TRIGGER set_conversations_updated_at
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_wallets_updated_at ON public.wallets;
CREATE TRIGGER set_wallets_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
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
CREATE POLICY "Users can view own account"
  ON public.accounts FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own account"
  ON public.accounts FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================
-- Anyone authenticated can view active profiles (for discovery)
CREATE POLICY "Authenticated users can view active profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.accounts
      WHERE accounts.id = profiles.id
      AND accounts.status = 'active'
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.blocks
      WHERE blocks.blocker_id = profiles.id
      AND blocks.blocked_id = auth.uid()
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.blocks
      WHERE blocks.blocker_id = auth.uid()
      AND blocks.blocked_id = profiles.id
    )
  );

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- CONVERSATIONS POLICIES
-- ============================================================================
CREATE POLICY "Users can view own conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() IN (participant_1, participant_2));

CREATE POLICY "Users can create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() IN (participant_1, participant_2));

CREATE POLICY "Users can update own conversations"
  ON public.conversations FOR UPDATE
  USING (auth.uid() IN (participant_1, participant_2))
  WITH CHECK (auth.uid() IN (participant_1, participant_2));

-- ============================================================================
-- MESSAGES POLICIES
-- ============================================================================
CREATE POLICY "Users can view messages in their conversations"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = messages.conversation_id
      AND auth.uid() IN (conversations.participant_1, conversations.participant_2)
    )
    AND messages.status != 'deleted'
  );

CREATE POLICY "Users can send messages in their conversations"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = conversation_id
      AND auth.uid() IN (conversations.participant_1, conversations.participant_2)
    )
  );

CREATE POLICY "Users can update their own messages"
  ON public.messages FOR UPDATE
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

-- ============================================================================
-- CALLS POLICIES
-- ============================================================================
CREATE POLICY "Users can view their own calls"
  ON public.calls FOR SELECT
  USING (auth.uid() IN (caller_id, callee_id));

CREATE POLICY "Users can create calls they initiate"
  ON public.calls FOR INSERT
  WITH CHECK (auth.uid() = caller_id);

CREATE POLICY "Users can update calls they're part of"
  ON public.calls FOR UPDATE
  USING (auth.uid() IN (caller_id, callee_id))
  WITH CHECK (auth.uid() IN (caller_id, callee_id));

-- ============================================================================
-- WALLETS POLICIES
-- ============================================================================
CREATE POLICY "Users can view own wallet"
  ON public.wallets FOR SELECT
  USING (auth.uid() = id);

-- Only service role can update wallets (through functions)
-- Users cannot directly modify wallet balances

-- ============================================================================
-- WALLET TRANSACTIONS POLICIES
-- ============================================================================
CREATE POLICY "Users can view own wallet transactions"
  ON public.wallet_transactions FOR SELECT
  USING (wallet_id = auth.uid());

-- ============================================================================
-- BLOCKS POLICIES
-- ============================================================================
CREATE POLICY "Users can view their blocks"
  ON public.blocks FOR SELECT
  USING (auth.uid() = blocker_id);

CREATE POLICY "Users can create blocks"
  ON public.blocks FOR INSERT
  WITH CHECK (auth.uid() = blocker_id);

CREATE POLICY "Users can delete their blocks"
  ON public.blocks FOR DELETE
  USING (auth.uid() = blocker_id);

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================
CREATE POLICY "Users can view their own reports"
  ON public.reports FOR SELECT
  USING (auth.uid() = reporter_id);

CREATE POLICY "Users can create reports"
  ON public.reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get or create conversation between two users
CREATE OR REPLACE FUNCTION public.get_or_create_conversation(
  user1_id UUID,
  user2_id UUID
)
RETURNS UUID AS $$
DECLARE
  conv_id UUID;
  p1 UUID;
  p2 UUID;
BEGIN
  -- Ensure consistent ordering
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================
DO $$
BEGIN
  RAISE NOTICE 'IshqTalk database schema created successfully!';
  RAISE NOTICE 'Tables created: accounts, profiles, conversations, messages, calls, wallets, wallet_transactions, blocks, reports';
  RAISE NOTICE 'Row Level Security enabled on all tables';
  RAISE NOTICE 'Triggers configured for automatic account/wallet/profile creation';
END $$;
