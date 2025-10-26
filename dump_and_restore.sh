#!/bin/bash
# Simple dump and restore using pg_dump/pg_restore

echo "📤 Dumping local database..."
pg_dump -d vocab_atlas -U postgres -F c -f vocab_atlas_backup.dump

echo ""
echo "✅ Backup created: vocab_atlas_backup.dump"
echo ""
echo "To restore on VPS:"
echo "scp vocab_atlas_backup.dump root@142.171.47.157:/var/www/maxvocab/"
echo "ssh root@142.171.47.157"
echo "cd /var/www/maxvocab"
echo "dropdb vocab_atlas"
echo "createdb vocab_atlas"
echo "pg_restore -d vocab_atlas vocab_atlas_backup.dump"
