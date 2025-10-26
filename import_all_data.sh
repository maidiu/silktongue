#!/bin/bash
# Import all data to VPS - vocab, quizzes, stories, and tower data

echo "📥 Importing all data to VPS..."
echo ""

# Import vocabulary
echo "1️⃣ Importing vocabulary entries..."
sudo -u postgres psql -d vocab_atlas -f vocab_data_export.sql > /dev/null 2>&1

# Reset the sequence
echo "2️⃣ Resetting sequences..."
sudo -u postgres psql -d vocab_atlas -c "SELECT setval('vocab_entries_id_seq', (SELECT MAX(id) FROM vocab_entries) + 1);" > /dev/null 2>&1

# Import quizzes
echo "3️⃣ Importing quiz materials..."
sudo -u postgres psql -d vocab_atlas -f quiz_data_export.sql > /dev/null 2>&1

# Import story questions
echo "4️⃣ Importing story comprehension questions..."
sudo -u postgres psql -d vocab_atlas -f story_data_export.sql > /dev/null 2>&1

# Import tower data
echo "5️⃣ Importing tower maps/floors/rooms..."
sudo -u postgres psql -d vocab_atlas -f tower_data_export.sql > /dev/null 2>&1

# Reset sequences for maps/floors/rooms
echo "6️⃣ Resetting tower sequences..."
sudo -u postgres psql -d vocab_atlas -c "
  SELECT setval('maps_id_seq', (SELECT MAX(id) FROM maps) + 1);
  SELECT setval('floors_id_seq', (SELECT MAX(id) FROM floors) + 1);
  SELECT setval('rooms_id_seq', (SELECT MAX(id) FROM rooms) + 1);
" > /dev/null 2>&1

echo ""
echo "✅ All data imported!"
echo ""
echo "📊 Summary:"
sudo -u postgres psql -d vocab_atlas -c "SELECT 'vocab_entries:', COUNT(*) FROM vocab_entries; SELECT 'quiz_materials:', COUNT(*) FROM quiz_materials; SELECT 'story_comprehension_questions:', COUNT(*) FROM story_comprehension_questions; SELECT 'maps:', COUNT(*) FROM maps; SELECT 'floors:', COUNT(*) FROM floors; SELECT 'rooms:', COUNT(*) FROM rooms;"
