#!/bin/bash
# Simple restore: drop, create, restore

cd /var/www/maxvocab

echo "🗑️  Dropping database..."
su - postgres -c "dropdb vocab_atlas 2>/dev/null || true"

echo "✨ Creating database..."
su - postgres -c "createdb vocab_atlas"

echo "📥 Restoring from dump..."
su - postgres -c "pg_restore -d vocab_atlas vocab_atlas.dump"

echo "✅ Done!"

