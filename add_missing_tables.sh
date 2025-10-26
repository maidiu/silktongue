#!/bin/bash
# Add missing tables to existing VPS database

echo "🔧 Adding missing tables to your VPS database..."
echo ""
echo "This will add the missing 16 tables without dropping existing data."
echo ""

# On your VPS, run this:
echo "sudo -u postgres psql -d vocab_atlas -f server/sql/complete_schema.sql"
echo ""
echo "This will create any missing tables while preserving existing data."

