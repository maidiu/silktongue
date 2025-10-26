#!/bin/bash
# Restore vocab_atlas.dump to VPS

echo "📥 Uploading vocab_atlas.dump to VPS..."
scp vocab_atlas.dump root@142.171.47.157:/var/www/maxvocab/

echo ""
echo "Now SSH to VPS and run:"
echo "  cd /var/www/maxvocab"
echo "  pg_restore -U postgres -d vocab_atlas --clean --if-exists vocab_atlas.dump"
echo ""
echo "This will restore your complete local database to VPS"

