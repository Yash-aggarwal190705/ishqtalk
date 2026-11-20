-- Quick test to verify schema is working
-- Run this in Supabase SQL Editor after running supabase_schema.sql

-- Check all tables exist
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE columns.table_name = tables.table_name) as column_count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('accounts', 'profiles', 'conversations', 'messages', 'calls', 'wallets', 'wallet_transactions', 'blocks', 'reports')
ORDER BY table_name;

-- Expected result: 9 rows with table names and their column counts
