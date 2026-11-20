# 🗄️ How to Run the Database Schema in Supabase

## Step-by-Step Visual Guide

### 1. Open Your Supabase Project

Go to: **https://pqbvflfkhnqgaeczdaoh.supabase.co**

(Or go to supabase.com and click on your project)

---

### 2. Navigate to SQL Editor

On the left sidebar, click on:
```
🔧 SQL Editor
```

Or use the URL directly:
**https://pqbvflfkhnqgaeczdaoh.supabase.co/project/pqbvflfkhnqgaeczdaoh/sql/new**

---

### 3. Create New Query

Click the button:
```
+ New Query
```

You'll see a blank SQL editor.

---

### 4. Copy the SQL Schema

Open the file: `d:\IshqTalk\ishqtalk\supabase_schema.sql`

**Select all** (Ctrl+A) and **Copy** (Ctrl+C)

---

### 5. Paste into Supabase

Click in the SQL editor and **Paste** (Ctrl+V)

You should see something like:
```sql
-- IshqTalk Database Schema for Supabase
-- Run this in Supabase SQL Editor...

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
...
```

---

### 6. Run the Query

Click the **Run** button in the top right

Or press: **Ctrl + Enter**

---

### 7. Wait for Completion

You should see in the bottom panel:
```
✓ Success. No rows returned
```

And a notice message:
```
NOTICE: IshqTalk database schema created successfully!
NOTICE: Tables created: accounts, profiles, conversations, messages, calls, wallets, wallet_transactions, blocks, reports
NOTICE: Row Level Security enabled on all tables
NOTICE: Triggers configured for automatic account/wallet/profile creation
```

---

### 8. Verify Tables Were Created

Click on **Table Editor** in the left sidebar

You should see these tables:
- ✅ accounts
- ✅ blocks
- ✅ calls
- ✅ conversations
- ✅ messages
- ✅ profiles
- ✅ reports
- ✅ wallet_transactions
- ✅ wallets

---

## ✅ Success!

Your database is now ready!

### What Was Created:

**9 Tables:**
1. accounts - User accounts
2. profiles - Public profiles
3. conversations - Chat conversations
4. messages - Chat messages
5. calls - Video call history
6. wallets - Virtual currency
7. wallet_transactions - Transaction log
8. blocks - User blocking
9. reports - Safety reports

**Security:**
- Row Level Security enabled on all tables
- Policies configured for proper access control

**Automation:**
- New users automatically get:
  - Account record
  - Wallet with 100 coins
  - Welcome bonus transaction
  - Profile record

---

## 🧪 Test It!

Now run your Flutter app:

```bash
# Windows
run_dev.bat

# Or
flutter run
```

Try to:
1. Register a new account
2. Check the **Authentication** → **Users** tab in Supabase
3. Check the **Table Editor** → **accounts** table
4. You should see your new account!

---

## ❌ Troubleshooting

### Error: "extension uuid-ossp already exists"
**Solution:** This is fine! It just means the extension was already installed. The script continues.

### Error: "table accounts already exists"
**Solution:** You've already run the schema. That's okay! The `IF NOT EXISTS` clauses prevent errors.

If you want to start fresh:
1. Go to **Database** → **Tables**
2. Delete all the IshqTalk tables
3. Run the schema again

### Error: "permission denied"
**Solution:** Make sure you're using the SQL Editor in your project, not trying to connect externally.

### Tables not showing up
**Solution:** 
1. Refresh the page
2. Check you're in the correct project
3. Click **Table Editor** → look for the `public` schema

---

## 📞 Need Help?

If something isn't working:

1. Check the error message in the SQL editor bottom panel
2. Make sure you copied the ENTIRE `supabase_schema.sql` file
3. Make sure you're in the correct Supabase project
4. Try refreshing the Supabase dashboard

The schema is designed to be idempotent (safe to run multiple times) so you can always try running it again!

---

## 🎉 Next Steps

Once the schema is running:

1. ✅ Test user registration in your app
2. ✅ Check users appear in Supabase
3. ✅ Start building features!

See `SETUP_COMPLETE.md` for the full checklist.
