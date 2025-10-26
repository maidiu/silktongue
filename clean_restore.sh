#!/bin/bash
# Drop and recreate the database, then restore from dump

export PGHOST=/var/run/postgresql

echo "🗑️  Dropping existing database..."
sudo -u postgres psql -d postgres -c "DROP DATABASE IF EXISTS vocab_atlas;"

echo "✨ Creating fresh database..."
sudo -u postgres psql -d postgres -c "CREATE DATABASE vocab_atlas;"

echo "📥 Restoring from dump..."
sudo -u postgres pg_restore -d vocab_atlas vocab_atlas.dump

echo "✅ Done!"
echo ""
echo "📊 Verifying import..."
sudo -u postgres psql -d vocab_atlas -c "SELECT 'vocab_entries:', COUNT(*) FROM vocab_entries; SELECT 'quiz_materials:', COUNT(*) FROM quiz_materials; SELECT 'story_comprehension_questions:', COUNT(*) FROM story_comprehension_questions; SELECT 'rooms:', COUNT(*) FROM rooms;"
