-- Tower of Words Initialization Data
-- This file creates maps, floors, and rooms for all vocabulary entries

-- First, create the main map
INSERT INTO maps (id, name, description, total_floors, created_at)
VALUES (1, 'The Tower of Words', 'A journey through the lexicon, floor by floor, word by word.', 2, NOW())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  total_floors = EXCLUDED.total_floors,
  created_at = EXCLUDED.created_at;

-- Floor 1: First 8 words (Week 1: impede, inherent, cohesive, scattershot, salient, omit, perfunctory, verisimilitude)
-- Note: Using word IDs 1-8 based on the insertion order
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 1, 'Floor 1: The First Chamber', 'Eight powerful words await mastery on this floor...', 150, NOW())
ON CONFLICT (map_id, floor_number) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  silk_reward = EXCLUDED.silk_reward;

-- Get floor 1 ID
DO $$
DECLARE
    floor1_id INTEGER;
BEGIN
    SELECT id INTO floor1_id FROM floors WHERE map_id = 1 AND floor_number = 1;
    
    -- Create rooms for Floor 1 (words with IDs 108-115 based on the ingestion output)
    -- impede (word_id ~108-127 range from the logs), inherent, cohesive, scattershot, salient, omit, perfunctory, verisimilitude
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 1, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 40, 30, false, NOW()
    FROM vocab_entries WHERE word = 'impede';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 2, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 50, 35, false, NOW()
    FROM vocab_entries WHERE word = 'inherent';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 3, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 60, 40, false, NOW()
    FROM vocab_entries WHERE word = 'cohesive';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 4, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 70, 45, false, NOW()
    FROM vocab_entries WHERE word = 'scattershot';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 5, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 80, 50, false, NOW()
    FROM vocab_entries WHERE word = 'salient';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 6, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 90, 55, false, NOW()
    FROM vocab_entries WHERE word = 'omit';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 7, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 100, 60, false, NOW()
    FROM vocab_entries WHERE word = 'perfunctory';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor1_id, 8, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 110, 65, true, NOW()
    FROM vocab_entries WHERE word = 'verisimilitude';
END $$;

-- Floor 2: Second 8 words (Week 2: attest, pall, lumbering, scurry, steadfast, elucidate, plausible, ubiquitous)
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 2, 'Floor 2: The Second Chamber', 'Eight powerful words await mastery on this floor...', 200, NOW())
ON CONFLICT (map_id, floor_number) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  silk_reward = EXCLUDED.silk_reward;

DO $$
DECLARE
    floor2_id INTEGER;
BEGIN
    SELECT id INTO floor2_id FROM floors WHERE map_id = 1 AND floor_number = 2;
    
    -- Create rooms for Floor 2
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 1, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 120, 70, false, NOW()
    FROM vocab_entries WHERE word = 'attest';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 2, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 130, 75, false, NOW()
    FROM vocab_entries WHERE word = 'pall';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 3, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 140, 80, false, NOW()
    FROM vocab_entries WHERE word = 'lumbering';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 4, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 150, 85, false, NOW()
    FROM vocab_entries WHERE word = 'scurry';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 5, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 160, 90, false, NOW()
    FROM vocab_entries WHERE word = 'steadfast';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 6, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 170, 95, false, NOW()
    FROM vocab_entries WHERE word = 'elucidate';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 7, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 180, 100, false, NOW()
    FROM vocab_entries WHERE word = 'plausible';
    
    INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
    SELECT floor2_id, 8, id, 'The Room of ' || word, 'Master ' || word || ' and unlock its power.', 190, 105, true, NOW()
    FROM vocab_entries WHERE word = 'ubiquitous';
END $$;
