#!/bin/bash

# Script to check Render PostgreSQL database size and table breakdown
# Replace with your actual Render database connection string

echo "=== Render PostgreSQL Database Size Analysis ==="
echo ""

# You need to get your DATABASE_URL from Render dashboard
# Format: postgresql://user:password@host:port/database

# Example (replace with your actual connection string):
# DATABASE_URL="postgresql://ace_user:password@dpg-xxxxx.oregon-postgres.render.com/ace_supermarket"

# Uncomment and replace with your actual DATABASE_URL:
# export DATABASE_URL="your_render_database_url_here"

if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL not set"
    echo ""
    echo "To use this script:"
    echo "1. Go to Render Dashboard → Your PostgreSQL Database"
    echo "2. Copy the 'External Database URL' or 'Internal Database URL'"
    echo "3. Run: export DATABASE_URL='your_connection_string'"
    echo "4. Then run this script again"
    exit 1
fi

echo "📊 Total Database Size:"
psql "$DATABASE_URL" -c "SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size;"

echo ""
echo "📋 All Tables with Sizes and Row Counts:"
psql "$DATABASE_URL" -c "
SELECT 
    schemaname||'.'||tablename AS table_name,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

echo ""
echo "📈 Top 10 Largest Tables:"
psql "$DATABASE_URL" -c "
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size('public.'||tablename) DESC 
LIMIT 10;
"

echo ""
echo "🔢 Row Counts for All Tables:"
psql "$DATABASE_URL" -c "
SELECT 
    relname AS table_name,
    n_live_tup AS row_count,
    pg_size_pretty(pg_total_relation_size('public.'||relname)) AS size
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC;
"

echo ""
echo "💾 Database Breakdown:"
psql "$DATABASE_URL" -c "
SELECT 
    pg_size_pretty(SUM(pg_total_relation_size(schemaname||'.'||tablename))::bigint) AS tables_total,
    pg_size_pretty(pg_database_size(current_database()) - SUM(pg_total_relation_size(schemaname||'.'||tablename))::bigint) AS overhead
FROM pg_tables 
WHERE schemaname = 'public';
"

echo ""
echo "✅ Analysis Complete!"
