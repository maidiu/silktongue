#!/bin/bash
# Import COMPLETE database from local machine

echo "📥 Importing COMPLETE database to VPS..."
echo ""

# Import everything
echo "Importing complete database export..."
sudo -u postgres psql -d vocab_atlas -f complete_database_export.sql

echo ""
echo "✅ All data imported!"
echo ""
echo "📊 Summary:"
sudo -u postgres psql -d vocab_atlas -c "SELECT 'vocab_entries:', COUNT(*) FROM vocab_entries; SELECT 'word_timeline_events:', COUNT(*) FROM word_timeline_events; SELECT 'word_relations:', COUNT(*) FROM word_relations; SELECT 'quiz_materials:', COUNT(*) FROM quiz_materials; SELECT 'story_comprehension_questions:', COUNT(*) FROM story_comprehension_questions; SELECT 'maps:', COUNT(*) FROM maps; SELECT 'floors:', COUNT(*) FROM floors; SELECT 'rooms:', COUNT(*) FROM rooms;"
