-- Maps System Schema
-- Creates the dungeon-crawling vocabulary adventure system

-- Maps table - represents the overall map structure
CREATE TABLE IF NOT EXISTS maps (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    total_floors INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Floors table - represents each floor/batch of words
CREATE TABLE IF NOT EXISTS floors (
    id SERIAL PRIMARY KEY,
    map_id INTEGER REFERENCES maps(id) ON DELETE CASCADE,
    floor_number INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    unlock_requirement TEXT, -- Description of what's needed to unlock this floor
    boss_challenge_type TEXT DEFAULT 'scenario_typing', -- Type of floor boss challenge
    silk_reward INTEGER DEFAULT 100, -- Silk reward for completing the floor
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(map_id, floor_number)
);

-- Rooms table - represents individual words as rooms
CREATE TABLE IF NOT EXISTS rooms (
    id SERIAL PRIMARY KEY,
    floor_id INTEGER REFERENCES floors(id) ON DELETE CASCADE,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    room_number INTEGER NOT NULL,
    name TEXT NOT NULL, -- Display name for the room
    description TEXT,
    silk_cost INTEGER DEFAULT 50, -- Silk cost to unlock this room
    silk_reward INTEGER DEFAULT 25, -- Silk reward for completing this room
    is_boss_room BOOLEAN DEFAULT FALSE, -- True for floor boss rooms
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(floor_id, room_number)
);

-- Floor boss scenarios table - stores the scenario-based challenges
CREATE TABLE IF NOT EXISTS floor_boss_scenarios (
    id SERIAL PRIMARY KEY,
    floor_id INTEGER REFERENCES floors(id) ON DELETE CASCADE,
    scenario_text TEXT NOT NULL, -- The scenario description
    correct_word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    difficulty_level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User map progress table - tracks user's progress through the maps
CREATE TABLE IF NOT EXISTS user_map_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    map_id INTEGER REFERENCES maps(id) ON DELETE CASCADE,
    current_floor INTEGER DEFAULT 1,
    current_room INTEGER DEFAULT 1,
    floors_completed INTEGER DEFAULT 0,
    total_silk_spent INTEGER DEFAULT 0,
    total_silk_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, map_id)
);

-- User room unlocks table - tracks which rooms each user has unlocked
CREATE TABLE IF NOT EXISTS user_room_unlocks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    room_id INTEGER REFERENCES rooms(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    silk_spent INTEGER DEFAULT 0,
    silk_earned INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, room_id)
);

-- User floor boss attempts table - tracks floor boss challenge attempts
CREATE TABLE IF NOT EXISTS user_floor_boss_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    floor_id INTEGER REFERENCES floors(id) ON DELETE CASCADE,
    scenarios_presented JSONB, -- Array of scenario IDs that were presented
    user_responses JSONB, -- Array of user's word responses
    correct_count INTEGER DEFAULT 0,
    total_scenarios INTEGER DEFAULT 0,
    success BOOLEAN DEFAULT FALSE,
    silk_earned INTEGER DEFAULT 0,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_floors_map_id ON floors(map_id);
CREATE INDEX IF NOT EXISTS idx_rooms_floor_id ON rooms(floor_id);
CREATE INDEX IF NOT EXISTS idx_rooms_word_id ON rooms(word_id);
CREATE INDEX IF NOT EXISTS idx_floor_boss_scenarios_floor_id ON floor_boss_scenarios(floor_id);
CREATE INDEX IF NOT EXISTS idx_user_map_progress_user_id ON user_map_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_room_unlocks_user_id ON user_room_unlocks(user_id);
CREATE INDEX IF NOT EXISTS idx_user_room_unlocks_room_id ON user_room_unlocks(room_id);
CREATE INDEX IF NOT EXISTS idx_user_floor_boss_attempts_user_id ON user_floor_boss_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_floor_boss_attempts_floor_id ON user_floor_boss_attempts(floor_id);

-- Add updated_at trigger for user_map_progress
CREATE TRIGGER update_user_map_progress_updated_at
BEFORE UPDATE ON user_map_progress
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
