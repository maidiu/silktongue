#!/bin/bash
# Restore the local database dump on VPS

echo "⚠️  This will REPLACE all data in vocab_atlas on VPS!"
read -p "Type 'RESTORE VPS' to continue: " confirm
if [ "$confirm" != "RESTORE VPS" ]; then
    echo "❌ Cancelled"
    exit 1
fi

echo "Restoring database..."
sudo -u postgres psql -d vocab_atlas < local_db_backup.sql

echo "✅ Done! Your VPS database now matches your local database."

