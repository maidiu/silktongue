#!/bin/bash
# Completely wipe and rebuild database from full_schema.sql

echo "⚠️  THIS WILL DELETE ALL DATA IN vocab_atlas!"
echo ""
echo "This will:"
echo "1. Drop the vocab_atlas database"
echo "2. Recreate it"
echo "3. Apply full_schema.sql"
echo "4. Grant permissions"
echo ""
read -p "Type 'WIPE EVERYTHING' to continue: " confirm
if [ "$confirm" != "WIPE EVERYTHING" ]; then
    echo "❌ Cancelled"
    exit 1
fi

echo ""
echo "🗑️  Dropping database..."
sudo -u postgres psql << 'EOF'
DROP DATABASE IF EXISTS vocab_atlas;
CREATE DATABASE vocab_atlas OWNER vocab_atlas_user;
EOF

echo "✅ Database recreated"
echo ""
echo "📊 Applying complete_schema.sql..."
sudo -u postgres psql -d vocab_atlas -f server/sql/complete_schema.sql

echo "✅ Schema applied"
echo ""
echo "📝 Granting permissions..."
sudo -u postgres psql -d vocab_atlas << 'EOF'
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vocab_atlas_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vocab_atlas_user;
GRANT USAGE ON SCHEMA public TO vocab_atlas_user;
EOF

echo ""
echo "✅ Database wiped and rebuilt!"
echo ""
echo "Now import your data:"
echo "cd server"
echo "node scripts/ingest_vocab.js ../weekly_entries/2025.10.17.json"
echo "node scripts/ingest_vocab.js ../weekly_entries/2025.10.25.json"
echo "node scripts/ingest_quizzes.js ../weekly_quizzes/levels_1-5_2025.10.25.json"
echo "node scripts/ingest_quizzes.js ../weekly_quizzes/level6_quizzes_2025.10.25.json"
echo "node scripts/import_story_questions.js"
echo "cd .."
echo "./import_week2_story_questions.sh"

