#!/bin/bash
# Import CORE data from local machine (tables that match VPS schema)

echo "📥 Importing CORE data to VPS..."
echo ""

# Import core tables
echo "Importing core data export..."
sudo -u postgres psql -d vocab_atlas -f core_data_export.sql

echo ""
echo "✅ Core data imported!"
echo ""
echo "📊 Summary:"
sudo -u postgres psql -d vocab_atlas -c "SELECT 'vocab_entries:', COUNT(*) FROM vocab_entries; SELECT 'quiz_materials:', COUNT(*) FROM quiz_materials; SELECT 'story_comprehension_questions:', COUNT(*) FROM story_comprehension_questions; SELECT 'maps:', COUNT(*) FROM maps; SELECT 'floors:', COUNT(*) FROM floors; SELECT 'rooms:', COUNT(*) FROM rooms;"
