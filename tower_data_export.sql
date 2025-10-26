-- Tower of Words Data Export
-- Generated on 2025-10-26T05:06:18.402Z

-- Create the main map
INSERT INTO maps (id, name, description, total_floors, created_at)
VALUES (1, 'The Tower of Words', 'A journey through the lexicon, floor by floor, word by word.', 27, NOW())
ON CONFLICT (id) DO UPDATE SET total_floors = EXCLUDED.total_floors;


-- Floor 1: impede and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 1, 'Floor 1: impede and Companions', 'Eight powerful words await mastery on this floor...', 150, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 1, 1, 'The Room of impede', 'Master impede and unlock its power.', 60, 40, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 2, 2, 'The Room of obstruction', 'Master obstruction and unlock its power.', 70, 45, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 3, 3, 'The Room of delay', 'Master delay and unlock its power.', 80, 50, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 4, 4, 'The Room of resistance', 'Master resistance and unlock its power.', 90, 55, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 5, 5, 'The Room of inhibition', 'Master inhibition and unlock its power.', 100, 60, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 6, 6, 'The Room of assist', 'Master assist and unlock its power.', 110, 65, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 7, 7, 'The Room of facilitate', 'Master facilitate and unlock its power.', 120, 70, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 1), 8, 8, 'The Room of enable', 'Master enable and unlock its power.', 130, 75, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 2: promote and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 2, 'Floor 2: promote and Companions', 'Eight powerful words await mastery on this floor...', 200, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 1, 9, 'The Room of promote', 'Master promote and unlock its power.', 80, 50, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 2, 10, 'The Room of advance', 'Master advance and unlock its power.', 90, 55, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 3, 11, 'The Room of impediment', 'Master impediment and unlock its power.', 100, 60, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 4, 12, 'The Room of expedite', 'Master expedite and unlock its power.', 110, 65, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 5, 13, 'The Room of inherent', 'Master inherent and unlock its power.', 120, 70, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 6, 14, 'The Room of intrinsic', 'Master intrinsic and unlock its power.', 130, 75, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 7, 15, 'The Room of innate', 'Master innate and unlock its power.', 140, 80, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 2), 8, 16, 'The Room of essential', 'Master essential and unlock its power.', 150, 85, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 3: built-in and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 3, 'Floor 3: built-in and Companions', 'Eight powerful words await mastery on this floor...', 250, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 1, 17, 'The Room of built-in', 'Master built-in and unlock its power.', 100, 60, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 2, 18, 'The Room of fundamental', 'Master fundamental and unlock its power.', 110, 65, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 3, 19, 'The Room of native', 'Master native and unlock its power.', 120, 70, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 4, 20, 'The Room of external', 'Master external and unlock its power.', 130, 75, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 5, 21, 'The Room of acquired', 'Master acquired and unlock its power.', 140, 80, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 6, 22, 'The Room of extrinsic', 'Master extrinsic and unlock its power.', 150, 85, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 7, 23, 'The Room of adventitious', 'Master adventitious and unlock its power.', 160, 90, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 3), 8, 24, 'The Room of inherit', 'Master inherit and unlock its power.', 170, 95, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 4: adhere and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 4, 'Floor 4: adhere and Companions', 'Eight powerful words await mastery on this floor...', 300, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 1, 25, 'The Room of adhere', 'Master adhere and unlock its power.', 120, 70, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 2, 26, 'The Room of cohere', 'Master cohere and unlock its power.', 130, 75, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 3, 27, 'The Room of cohesive', 'Master cohesive and unlock its power.', 140, 80, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 4, 28, 'The Room of unified', 'Master unified and unlock its power.', 150, 85, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 5, 29, 'The Room of connected', 'Master connected and unlock its power.', 160, 90, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 6, 30, 'The Room of integrated', 'Master integrated and unlock its power.', 170, 95, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 7, 31, 'The Room of consistent', 'Master consistent and unlock its power.', 180, 100, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 4), 8, 32, 'The Room of harmonious', 'Master harmonious and unlock its power.', 190, 105, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 5: fragmented and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 5, 'Floor 5: fragmented and Companions', 'Eight powerful words await mastery on this floor...', 350, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 1, 33, 'The Room of fragmented', 'Master fragmented and unlock its power.', 140, 80, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 2, 34, 'The Room of disjointed', 'Master disjointed and unlock its power.', 150, 85, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 3, 35, 'The Room of dispersed', 'Master dispersed and unlock its power.', 160, 90, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 4, 36, 'The Room of incoherent', 'Master incoherent and unlock its power.', 170, 95, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 5, 37, 'The Room of scattered', 'Master scattered and unlock its power.', 180, 100, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 6, 38, 'The Room of disconnected', 'Master disconnected and unlock its power.', 190, 105, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 7, 40, 'The Room of cohesion', 'Master cohesion and unlock its power.', 200, 110, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 5), 8, 42, 'The Room of scattershot', 'Master scattershot and unlock its power.', 210, 115, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 6: haphazard and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 6, 'Floor 6: haphazard and Companions', 'Eight powerful words await mastery on this floor...', 400, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 1, 43, 'The Room of haphazard', 'Master haphazard and unlock its power.', 160, 90, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 2, 44, 'The Room of indiscriminate', 'Master indiscriminate and unlock its power.', 170, 95, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 3, 45, 'The Room of unfocused', 'Master unfocused and unlock its power.', 180, 100, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 4, 46, 'The Room of broad-brush', 'Master broad-brush and unlock its power.', 190, 105, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 5, 47, 'The Room of random', 'Master random and unlock its power.', 200, 110, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 6, 48, 'The Room of targeted', 'Master targeted and unlock its power.', 210, 115, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 7, 49, 'The Room of systematic', 'Master systematic and unlock its power.', 220, 120, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 6), 8, 50, 'The Room of methodical', 'Master methodical and unlock its power.', 230, 125, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 7: precise and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 7, 'Floor 7: precise and Companions', 'Eight powerful words await mastery on this floor...', 450, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 1, 51, 'The Room of precise', 'Master precise and unlock its power.', 180, 100, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 2, 52, 'The Room of focused', 'Master focused and unlock its power.', 190, 105, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 3, 53, 'The Room of shotgun', 'Master shotgun and unlock its power.', 200, 110, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 4, 54, 'The Room of scatter', 'Master scatter and unlock its power.', 210, 115, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 5, 55, 'The Room of aimless', 'Master aimless and unlock its power.', 220, 120, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 6, 56, 'The Room of salient', 'Master salient and unlock its power.', 230, 125, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 7, 57, 'The Room of prominent', 'Master prominent and unlock its power.', 240, 130, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 7), 8, 58, 'The Room of notable', 'Master notable and unlock its power.', 250, 135, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 8: striking and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 8, 'Floor 8: striking and Companions', 'Eight powerful words await mastery on this floor...', 500, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 1, 59, 'The Room of striking', 'Master striking and unlock its power.', 200, 110, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 2, 60, 'The Room of conspicuous', 'Master conspicuous and unlock its power.', 210, 115, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 3, 61, 'The Room of remarkable', 'Master remarkable and unlock its power.', 220, 120, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 4, 62, 'The Room of outstanding', 'Master outstanding and unlock its power.', 230, 125, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 5, 63, 'The Room of obscure', 'Master obscure and unlock its power.', 240, 130, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 6, 64, 'The Room of inconspicuous', 'Master inconspicuous and unlock its power.', 250, 135, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 7, 65, 'The Room of hidden', 'Master hidden and unlock its power.', 260, 140, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 8), 8, 66, 'The Room of minor', 'Master minor and unlock its power.', 270, 145, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 9: salience and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 9, 'Floor 9: salience and Companions', 'Eight powerful words await mastery on this floor...', 550, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 1, 67, 'The Room of salience', 'Master salience and unlock its power.', 220, 120, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 2, 68, 'The Room of saliently', 'Master saliently and unlock its power.', 230, 125, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 3, 69, 'The Room of resilient', 'Master resilient and unlock its power.', 240, 130, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 4, 70, 'The Room of perfunctory', 'Master perfunctory and unlock its power.', 250, 135, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 5, 71, 'The Room of cursory', 'Master cursory and unlock its power.', 260, 140, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 6, 72, 'The Room of mechanical', 'Master mechanical and unlock its power.', 270, 145, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 7, 73, 'The Room of superficial', 'Master superficial and unlock its power.', 280, 150, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 9), 8, 74, 'The Room of indifferent', 'Master indifferent and unlock its power.', 290, 155, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 10: unthinking and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 10, 'Floor 10: unthinking and Companions', 'Eight powerful words await mastery on this floor...', 600, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 1, 75, 'The Room of unthinking', 'Master unthinking and unlock its power.', 240, 130, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 2, 76, 'The Room of thorough', 'Master thorough and unlock its power.', 250, 135, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 3, 77, 'The Room of careful', 'Master careful and unlock its power.', 260, 140, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 4, 78, 'The Room of deliberate', 'Master deliberate and unlock its power.', 270, 145, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 5, 79, 'The Room of attentive', 'Master attentive and unlock its power.', 280, 150, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 6, 80, 'The Room of conscientious', 'Master conscientious and unlock its power.', 290, 155, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 7, 81, 'The Room of function', 'Master function and unlock its power.', 300, 160, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 10), 8, 82, 'The Room of perform', 'Master perform and unlock its power.', 310, 165, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 11: omit and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 11, 'Floor 11: omit and Companions', 'Eight powerful words await mastery on this floor...', 650, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 1, 83, 'The Room of omit', 'Master omit and unlock its power.', 260, 140, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 2, 84, 'The Room of exclude', 'Master exclude and unlock its power.', 270, 145, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 3, 85, 'The Room of leave out', 'Master leave out and unlock its power.', 280, 150, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 4, 86, 'The Room of skip', 'Master skip and unlock its power.', 290, 155, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 5, 87, 'The Room of neglect', 'Master neglect and unlock its power.', 300, 160, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 6, 88, 'The Room of ignore', 'Master ignore and unlock its power.', 310, 165, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 7, 89, 'The Room of include', 'Master include and unlock its power.', 320, 170, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 11), 8, 90, 'The Room of retain', 'Master retain and unlock its power.', 330, 175, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 12: insert and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 12, 'Floor 12: insert and Companions', 'Eight powerful words await mastery on this floor...', 700, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 1, 91, 'The Room of insert', 'Master insert and unlock its power.', 280, 150, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 2, 92, 'The Room of add', 'Master add and unlock its power.', 290, 155, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 3, 93, 'The Room of delete', 'Master delete and unlock its power.', 300, 160, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 4, 187, 'The Room of verisimilitude', 'Master verisimilitude and unlock its power.', 310, 165, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 5, 188, 'The Room of plausibility', 'Master plausibility and unlock its power.', 320, 170, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 6, 189, 'The Room of believability', 'Master believability and unlock its power.', 330, 175, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 7, 190, 'The Room of realism', 'Master realism and unlock its power.', 340, 180, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 12), 8, 191, 'The Room of authenticity', 'Master authenticity and unlock its power.', 350, 185, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 13: credibility and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 13, 'Floor 13: credibility and Companions', 'Eight powerful words await mastery on this floor...', 750, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 1, 192, 'The Room of credibility', 'Master credibility and unlock its power.', 300, 160, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 2, 193, 'The Room of implausibility', 'Master implausibility and unlock its power.', 310, 165, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 3, 194, 'The Room of incredibility', 'Master incredibility and unlock its power.', 320, 170, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 4, 195, 'The Room of unreality', 'Master unreality and unlock its power.', 330, 175, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 5, 196, 'The Room of falseness', 'Master falseness and unlock its power.', 340, 180, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 6, 197, 'The Room of verify', 'Master verify and unlock its power.', 350, 185, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 7, 198, 'The Room of similar', 'Master similar and unlock its power.', 360, 190, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 13), 8, 199, 'The Room of simulate', 'Master simulate and unlock its power.', 370, 195, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 14: versimilar and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 14, 'Floor 14: versimilar and Companions', 'Eight powerful words await mastery on this floor...', 800, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 1, 200, 'The Room of versimilar', 'Master versimilar and unlock its power.', 320, 170, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 2, 443, 'The Room of attest', 'Master attest and unlock its power.', 330, 175, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 3, 444, 'The Room of testify', 'Master testify and unlock its power.', 340, 180, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 4, 446, 'The Room of confirm', 'Master confirm and unlock its power.', 350, 185, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 5, 447, 'The Room of certify', 'Master certify and unlock its power.', 360, 190, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 6, 448, 'The Room of validate', 'Master validate and unlock its power.', 370, 195, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 7, 449, 'The Room of affirm', 'Master affirm and unlock its power.', 380, 200, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 14), 8, 450, 'The Room of deny', 'Master deny and unlock its power.', 390, 205, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 15: refute and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 15, 'Floor 15: refute and Companions', 'Eight powerful words await mastery on this floor...', 850, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 1, 451, 'The Room of refute', 'Master refute and unlock its power.', 340, 180, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 2, 452, 'The Room of dispute', 'Master dispute and unlock its power.', 350, 185, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 3, 453, 'The Room of contradict', 'Master contradict and unlock its power.', 360, 190, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 4, 454, 'The Room of testament', 'Master testament and unlock its power.', 370, 195, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 5, 456, 'The Room of attestation', 'Master attestation and unlock its power.', 380, 200, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 6, 457, 'The Room of pall', 'Master pall and unlock its power.', 390, 205, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 7, 458, 'The Room of shroud', 'Master shroud and unlock its power.', 400, 210, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 15), 8, 459, 'The Room of cloud', 'Master cloud and unlock its power.', 410, 215, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 16: gloom and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 16, 'Floor 16: gloom and Companions', 'Eight powerful words await mastery on this floor...', 900, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 1, 460, 'The Room of gloom', 'Master gloom and unlock its power.', 360, 190, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 2, 461, 'The Room of melancholy', 'Master melancholy and unlock its power.', 370, 195, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 3, 462, 'The Room of envelope', 'Master envelope and unlock its power.', 380, 200, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 4, 463, 'The Room of brightness', 'Master brightness and unlock its power.', 390, 205, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 5, 464, 'The Room of cheer', 'Master cheer and unlock its power.', 400, 210, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 6, 465, 'The Room of joy', 'Master joy and unlock its power.', 410, 215, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 7, 466, 'The Room of lightness', 'Master lightness and unlock its power.', 420, 220, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 16), 8, 467, 'The Room of appal', 'Master appal and unlock its power.', 430, 225, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 17: pale and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 17, 'Floor 17: pale and Companions', 'Eight powerful words await mastery on this floor...', 950, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 1, 468, 'The Room of pale', 'Master pale and unlock its power.', 380, 200, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 2, 469, 'The Room of lumbering', 'Master lumbering and unlock its power.', 390, 205, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 3, 470, 'The Room of clumsy', 'Master clumsy and unlock its power.', 400, 210, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 4, 471, 'The Room of awkward', 'Master awkward and unlock its power.', 410, 215, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 5, 472, 'The Room of ungainly', 'Master ungainly and unlock its power.', 420, 220, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 6, 473, 'The Room of clodding', 'Master clodding and unlock its power.', 430, 225, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 7, 474, 'The Room of plodding', 'Master plodding and unlock its power.', 440, 230, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 17), 8, 475, 'The Room of graceful', 'Master graceful and unlock its power.', 450, 235, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 18: agile and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 18, 'Floor 18: agile and Companions', 'Eight powerful words await mastery on this floor...', 1000, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 1, 476, 'The Room of agile', 'Master agile and unlock its power.', 400, 210, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 2, 477, 'The Room of nimble', 'Master nimble and unlock its power.', 410, 215, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 3, 478, 'The Room of elegant', 'Master elegant and unlock its power.', 420, 220, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 4, 479, 'The Room of swift', 'Master swift and unlock its power.', 430, 225, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 5, 480, 'The Room of lumber', 'Master lumber and unlock its power.', 440, 230, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 6, 483, 'The Room of scurry', 'Master scurry and unlock its power.', 450, 235, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 7, 484, 'The Room of hurry', 'Master hurry and unlock its power.', 460, 240, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 18), 8, 485, 'The Room of rush', 'Master rush and unlock its power.', 470, 245, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 19: dart and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 19, 'Floor 19: dart and Companions', 'Eight powerful words await mastery on this floor...', 1050, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 1, 486, 'The Room of dart', 'Master dart and unlock its power.', 420, 220, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 2, 487, 'The Room of dash', 'Master dash and unlock its power.', 430, 225, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 3, 488, 'The Room of scuttle', 'Master scuttle and unlock its power.', 440, 230, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 4, 489, 'The Room of amble', 'Master amble and unlock its power.', 450, 235, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 5, 490, 'The Room of saunter', 'Master saunter and unlock its power.', 460, 240, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 6, 491, 'The Room of stroll', 'Master stroll and unlock its power.', 470, 245, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 7, 492, 'The Room of linger', 'Master linger and unlock its power.', 480, 250, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 19), 8, 496, 'The Room of steadfast', 'Master steadfast and unlock its power.', 490, 255, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 20: loyal and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 20, 'Floor 20: loyal and Companions', 'Eight powerful words await mastery on this floor...', 1100, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 1, 497, 'The Room of loyal', 'Master loyal and unlock its power.', 440, 230, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 2, 498, 'The Room of faithful', 'Master faithful and unlock its power.', 450, 235, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 3, 499, 'The Room of constant', 'Master constant and unlock its power.', 460, 240, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 4, 500, 'The Room of unwavering', 'Master unwavering and unlock its power.', 470, 245, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 5, 501, 'The Room of resolute', 'Master resolute and unlock its power.', 480, 250, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 6, 502, 'The Room of firm', 'Master firm and unlock its power.', 490, 255, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 7, 503, 'The Room of fickle', 'Master fickle and unlock its power.', 500, 260, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 20), 8, 504, 'The Room of unreliable', 'Master unreliable and unlock its power.', 510, 265, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 21: wavering and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 21, 'Floor 21: wavering and Companions', 'Eight powerful words await mastery on this floor...', 1150, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 1, 505, 'The Room of wavering', 'Master wavering and unlock its power.', 460, 240, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 2, 506, 'The Room of inconstant', 'Master inconstant and unlock its power.', 470, 245, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 3, 507, 'The Room of unstable', 'Master unstable and unlock its power.', 480, 250, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 4, 508, 'The Room of steady', 'Master steady and unlock its power.', 490, 255, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 5, 509, 'The Room of stead', 'Master stead and unlock its power.', 500, 260, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 6, 510, 'The Room of stand', 'Master stand and unlock its power.', 510, 265, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 7, 511, 'The Room of elucidate', 'Master elucidate and unlock its power.', 520, 270, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 21), 8, 512, 'The Room of explain', 'Master explain and unlock its power.', 530, 275, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 22: clarify and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 22, 'Floor 22: clarify and Companions', 'Eight powerful words await mastery on this floor...', 1200, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 1, 513, 'The Room of clarify', 'Master clarify and unlock its power.', 480, 250, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 2, 514, 'The Room of illuminate', 'Master illuminate and unlock its power.', 490, 255, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 3, 515, 'The Room of expound', 'Master expound and unlock its power.', 500, 260, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 4, 516, 'The Room of unfold', 'Master unfold and unlock its power.', 510, 265, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 5, 517, 'The Room of explicate', 'Master explicate and unlock its power.', 520, 270, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 6, 519, 'The Room of confuse', 'Master confuse and unlock its power.', 530, 275, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 7, 520, 'The Room of muddle', 'Master muddle and unlock its power.', 540, 280, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 22), 8, 521, 'The Room of bewilder', 'Master bewilder and unlock its power.', 550, 285, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 23: complicate and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 23, 'Floor 23: complicate and Companions', 'Eight powerful words await mastery on this floor...', 1250, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 1, 522, 'The Room of complicate', 'Master complicate and unlock its power.', 500, 260, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 2, 523, 'The Room of lucid', 'Master lucid and unlock its power.', 510, 265, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 3, 524, 'The Room of lucidity', 'Master lucidity and unlock its power.', 520, 270, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 4, 525, 'The Room of elucidation', 'Master elucidation and unlock its power.', 530, 275, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 5, 526, 'The Room of translucent', 'Master translucent and unlock its power.', 540, 280, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 6, 527, 'The Room of plausible', 'Master plausible and unlock its power.', 550, 285, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 7, 528, 'The Room of credible', 'Master credible and unlock its power.', 560, 290, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 23), 8, 529, 'The Room of believable', 'Master believable and unlock its power.', 570, 295, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 24: reasonable and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 24, 'Floor 24: reasonable and Companions', 'Eight powerful words await mastery on this floor...', 1300, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 1, 530, 'The Room of reasonable', 'Master reasonable and unlock its power.', 520, 270, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 2, 531, 'The Room of convincing', 'Master convincing and unlock its power.', 530, 275, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 3, 532, 'The Room of persuasive', 'Master persuasive and unlock its power.', 540, 280, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 4, 533, 'The Room of specious', 'Master specious and unlock its power.', 550, 285, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 5, 534, 'The Room of implausible', 'Master implausible and unlock its power.', 560, 290, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 6, 535, 'The Room of incredible', 'Master incredible and unlock its power.', 570, 295, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 7, 536, 'The Room of unbelievable', 'Master unbelievable and unlock its power.', 580, 300, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 24), 8, 537, 'The Room of absurd', 'Master absurd and unlock its power.', 590, 305, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 25: ridiculous and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 25, 'Floor 25: ridiculous and Companions', 'Eight powerful words await mastery on this floor...', 1350, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 1, 538, 'The Room of ridiculous', 'Master ridiculous and unlock its power.', 540, 280, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 2, 539, 'The Room of applaud', 'Master applaud and unlock its power.', 550, 285, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 3, 540, 'The Room of plaudit', 'Master plaudit and unlock its power.', 560, 290, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 4, 541, 'The Room of applause', 'Master applause and unlock its power.', 570, 295, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 5, 542, 'The Room of ubiquitous', 'Master ubiquitous and unlock its power.', 580, 300, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 6, 543, 'The Room of omnipresent', 'Master omnipresent and unlock its power.', 590, 305, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 7, 544, 'The Room of pervasive', 'Master pervasive and unlock its power.', 600, 310, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 25), 8, 545, 'The Room of everywhere', 'Master everywhere and unlock its power.', 610, 315, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 26: universal and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 26, 'Floor 26: universal and Companions', 'Eight powerful words await mastery on this floor...', 1400, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 1, 546, 'The Room of universal', 'Master universal and unlock its power.', 560, 290, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 2, 547, 'The Room of commonplace', 'Master commonplace and unlock its power.', 570, 295, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 3, 548, 'The Room of rare', 'Master rare and unlock its power.', 580, 300, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 4, 549, 'The Room of scarce', 'Master scarce and unlock its power.', 590, 305, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 5, 550, 'The Room of uncommon', 'Master uncommon and unlock its power.', 600, 310, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 6, 551, 'The Room of unusual', 'Master unusual and unlock its power.', 610, 315, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 7, 552, 'The Room of absent', 'Master absent and unlock its power.', 620, 320, false, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 26), 8, 553, 'The Room of ubiquity', 'Master ubiquity and unlock its power.', 630, 325, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;

-- Floor 27: ubiquitously and Companions
INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)
VALUES (1, 27, 'Floor 27: ubiquitously and Companions', 'Eight powerful words await mastery on this floor...', 1450, NOW())
ON CONFLICT (map_id, floor_number) DO NOTHING;

INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)
SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = 27), 1, 554, 'The Room of ubiquitously', 'Master ubiquitously and unlock its power.', 580, 300, true, NOW()
ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;
