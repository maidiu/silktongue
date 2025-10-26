#!/bin/bash
# Clean deployment script - wipe database and rebuild from scratch

echo "🧹 CLEAN DEPLOYMENT - This will wipe the database!"
echo ""
echo "Current database contents:"
sudo -u postgres psql -d vocab_atlas -c "
SELECT 
  (SELECT COUNT(*) FROM vocab_entries) as vocab,
  (SELECT COUNT(*) FROM quiz_materials) as quizzes,
  (SELECT COUNT(*) FROM story_comprehension_questions) as story_questions,
  (SELECT COUNT(*) FROM word_timeline_events) as timeline_events;
"

echo ""
read -p "Type 'WIPE ALL DATA' to continue: " confirm
if [ "$confirm" != "WIPE ALL DATA" ]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo ""
echo "🔄 Dropping and recreating database..."
sudo -u postgres psql << 'EOF'
DROP DATABASE IF EXISTS vocab_atlas;
CREATE DATABASE vocab_atlas OWNER vocab_atlas_user;
GRANT ALL PRIVILEGES ON DATABASE vocab_atlas TO vocab_atlas_user;
\c vocab_atlas
GRANT ALL PRIVILEGES ON SCHEMA public TO vocab_atlas_user;
EOF

echo "✅ Database recreated"
echo ""
echo "📊 Applying complete schema..."
sudo -u postgres psql -d vocab_atlas -f server/sql/complete_schema.sql

echo "✅ Schema applied"
echo ""
echo "📝 Granting permissions to vocab_atlas_user..."
sudo -u postgres psql -d vocab_atlas << 'EOF'
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vocab_atlas_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vocab_atlas_user;
GRANT USAGE ON SCHEMA public TO vocab_atlas_user;
EOF

echo "✅ Permissions granted"
echo ""
echo "📈 Database is now clean and ready for data import!"
echo ""
echo "Next steps:"
echo "1. Run: cd server && node scripts/ingest_vocab.js ../weekly_entries/2025.10.17.json"
echo "2. Run: cd server && node scripts/ingest_vocab.js ../weekly_entries/2025.10.25.json"
echo "3. Run: cd server && node scripts/ingest_quizzes.js ../weekly_quizzes/levels_1-5_2025.10.25.json"
echo "4. Run: cd server && node scripts/ingest_quizzes.js ../weekly_quizzes/level6_quizzes_2025.10.25.json"
echo "5. Run: cd .. && ./import_week2_story_questions.sh"

