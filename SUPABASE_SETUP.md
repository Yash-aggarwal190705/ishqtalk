# 🚀 Supabase Setup Guide for IshqTalk

## Why Supabase?

✅ **Perfect Fit for Your Requirements:**
- PostgreSQL database (matches your relational domain model)
- REST API (aligns with your API_CONTRACT.md)
- Row Level Security (implements your authorization rules)
- Real-time subscriptions (for messages, call events)
- Storage for media (profile photos, messages)
- Edge functions (for custom business logic)
- Self-hostable (data sovereignty, GDPR compliance)

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Create a new project:
   - **Name:** ishqtalk-dev (or ishqtalk-prod)
   - **Database Password:** Generate a strong password
   - **Region:** Choose closest to your users (EU for GDPR)

## Step 2: Install Dependencies

```bash
cd d:\IshqTalk\ishqtalk
flutter pub get
```

## Step 3: Initialize Supabase in Your App

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://your-project.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your-anon-key-here',
    ),
  );
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(preferences: prefs));
}
```

## Step 4: Configure Environment Variables

Create `.env` file (add to .gitignore!):

```bash
# Development
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Never commit these files!
# Add to .gitignore:
# .env
# .env.*
```

Run with environment variables:

```bash
# Development
flutter run --dart-define=SUPABASE_URL=https://xxxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key

# Or use a script (recommended)
```

Create `scripts/run_dev.sh`:

```bash
#!/bin/bash
source .env
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Step 5: Update App.dart

```dart
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/data/supabase_auth_repository.dart';

// In MyApp's providers:
ChangeNotifierProvider(
  create: (_) => AuthState(
    repository: SupabaseAuthRepository(),
  )..restoreSession(),
),
```

## Step 6: Database Schema

Run this SQL in Supabase SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Accounts table (extends Supabase auth.users)
CREATE TABLE public.accounts (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  bio TEXT,
  date_of_birth DATE,
  gender TEXT,
  status TEXT NOT NULL DEFAULT 'pending_verification' 
    CHECK (status IN ('pending_verification', 'active', 'restricted', 'suspended', 'deletion_pending', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Trigger to create account on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.accounts (id, email, display_name, status)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'display_name',
    CASE 
      WHEN NEW.email_confirmed_at IS NULL THEN 'pending_verification'
      ELSE 'active'
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Row Level Security
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

-- Users can read their own account
CREATE POLICY "Users can view own account"
  ON public.accounts FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own account
CREATE POLICY "Users can update own account"
  ON public.accounts FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Profiles table (public profile information)
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
  is_host BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Anyone can view active profiles (for discovery)
CREATE POLICY "Public profiles are viewable by authenticated users"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.accounts
      WHERE accounts.id = profiles.id
      AND accounts.status = 'active'
    )
  );

-- Users can update own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Conversations table
CREATE TABLE public.conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_1 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  participant_2 UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(participant_1, participant_2)
);

-- RLS for conversations
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() IN (participant_1, participant_2));

-- Messages table
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'gift')),
  metadata JSONB,
  status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read', 'moderated', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  moderated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- Index for faster queries
CREATE INDEX idx_messages_conversation ON public.messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);

-- RLS for messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages in their conversations"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = messages.conversation_id
      AND auth.uid() IN (conversations.participant_1, conversations.participant_2)
    )
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

-- Wallet table (for virtual credits)
CREATE TABLE public.wallets (
  id UUID PRIMARY KEY REFERENCES public.accounts(id) ON DELETE CASCADE,
  balance_coins INTEGER NOT NULL DEFAULT 0 CHECK (balance_coins >= 0),
  balance_gems INTEGER NOT NULL DEFAULT 0 CHECK (balance_gems >= 0),
  lifetime_spent INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for wallets
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wallet"
  ON public.wallets FOR SELECT
  USING (auth.uid() = id);

-- Trigger to create wallet on account creation
CREATE OR REPLACE FUNCTION public.handle_new_account()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.wallets (id, balance_coins, balance_gems)
  VALUES (NEW.id, 100, 0); -- Welcome bonus
  
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.display_name, 'User'));
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_account_created
  AFTER INSERT ON public.accounts
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_account();

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER set_accounts_updated_at
  BEFORE UPDATE ON public.accounts
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_conversations_updated_at
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_wallets_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

## Step 7: Storage Buckets

Create storage buckets in Supabase Dashboard → Storage:

1. **avatars** - Profile photos
   - Public bucket
   - Max file size: 2MB
   - Allowed types: image/jpeg, image/png, image/webp

2. **photos** - Profile gallery photos
   - Public bucket
   - Max file size: 5MB
   - Allowed types: image/jpeg, image/png, image/webp

3. **messages** - Message media
   - Private bucket
   - Max file size: 10MB
   - Allowed types: image/jpeg, image/png, image/gif

## Step 8: Test Authentication

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://xxxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
```

Try registering a new account!

## Step 9: Configure Email Settings

In Supabase Dashboard → Authentication → Email Templates:

1. **Confirm Signup** - Welcome email with verification link
2. **Reset Password** - Password reset email
3. **Magic Link** - One-time login link (optional)

Configure SMTP (or use Supabase's built-in email):
- Settings → Authentication → Email → SMTP Settings

## Comparison: Firebase vs Supabase

| Feature | Firebase | Supabase | Winner |
|---------|----------|----------|--------|
| **Database** | NoSQL (Firestore) | PostgreSQL | ✅ **Supabase** (your domain model is relational) |
| **Auth** | Excellent | Excellent | Tie |
| **Real-time** | Yes | Yes (Postgres changes) | Tie |
| **Pricing** | Pay-per-operation | Fixed pricing + generous free tier | ✅ **Supabase** |
| **SQL Queries** | Limited | Full PostgreSQL | ✅ **Supabase** |
| **Self-hosting** | No | Yes | ✅ **Supabase** |
| **GDPR** | Vendor lock-in | EU regions + self-host | ✅ **Supabase** |
| **Storage** | Yes | Yes | Tie |
| **Functions** | Cloud Functions | Edge Functions (Deno) | Tie |
| **Maturity** | Very mature | Growing fast | Firebase (but Supabase catching up) |
| **Cost at scale** | Expensive | Predictable | ✅ **Supabase** |

### For IshqTalk Specifically:

✅ **Supabase is better because:**
- Your domain model (profiles, conversations, messages, wallet) is **relational**
- Complex queries (discovery, matching) need **SQL joins**
- Your API contract expects **REST endpoints**
- Cost model is more predictable with your expected usage
- GDPR/privacy requirements easier to meet
- Row Level Security matches your authorization model

❌ **Firebase would require:**
- Restructuring your entire domain model for NoSQL
- Denormalization (duplicating data everywhere)
- More complex client-side logic
- Higher costs at scale (reads/writes add up)
- Less control over data

## Next Steps

1. ✅ Install Supabase package (done)
2. ✅ Create Supabase project
3. ✅ Run database schema SQL
4. ✅ Configure authentication
5. ✅ Set up storage buckets
6. ✅ Update main.dart with initialization
7. ✅ Update app.dart to use SupabaseAuthRepository
8. ✅ Test registration/login
9. Build out other features using Supabase client

## Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase Guide](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage](https://supabase.com/docs/guides/storage)
- [Edge Functions](https://supabase.com/docs/guides/functions)

## Cost Estimate

**Free Tier (Perfect for development):**
- 500MB database
- 1GB storage
- 2GB bandwidth
- 50,000 monthly active users
- Unlimited API requests

**Pro Tier ($25/month):**
- 8GB database
- 100GB storage
- 250GB bandwidth
- 100,000 monthly active users

For your app with 10,000 users:
- Estimated cost: **Free to $25/month** (vs Firebase: $100-300/month)

## 🎯 Decision: Use Supabase

**Recommendation: Go with Supabase** because:
1. ✅ Matches your architecture and domain model
2. ✅ Better for your cost model
3. ✅ Easier to meet privacy requirements
4. ✅ Full SQL power for complex queries
5. ✅ Self-hostable for data sovereignty

You already have `SupabaseAuthRepository` ready to use!
