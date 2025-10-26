-- =============================================================================
-- COMPLETE SILKTONGUE DATABASE SCHEMA
-- =============================================================================
-- One file to rule them all - all tables for the complete app
-- Run this as postgres user for a fresh database
-- =============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- Helper function for updated_at timestamps
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- USERS & AUTH
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    silk_balance INTEGER DEFAULT 0,
    health_points INTEGER DEFAULT 3,
    max_health_points INTEGER DEFAULT 3,
    is_admin BOOLEAN DEFAULT false,
    avatar_config JSONB DEFAULT '{}',
    last_health_reset TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- VOCABULARY ENTRIES
-- =============================================================================

CREATE TABLE IF NOT EXISTS vocab_entries (
    id SERIAL PRIMARY KEY,
    word TEXT NOT NULL UNIQUE,
    part_of_speech TEXT,
    modern_definition TEXT,
    usage_example TEXT,
    synonyms TEXT[],
    antonyms TEXT[],
    collocations JSONB DEFAULT '{}',
    french_equivalent TEXT,
    russian_equivalent TEXT,
    cefr_level TEXT,
    pronunciation TEXT,
    is_mastered BOOLEAN DEFAULT false,
    learning_status VARCHAR(20) DEFAULT 'unmastered',
    story_text TEXT,
    contrastive_opening TEXT,
    structural_analysis TEXT,
    story_intro TEXT,
    definitions JSONB DEFAULT '{}',
    variant_forms TEXT[],
    english_synonyms TEXT[],
    english_antonyms TEXT[],
    french_synonyms TEXT[],
    french_root_cognates TEXT[],
    russian_synonyms TEXT[],
    russian_root_cognates TEXT[],
    common_collocations TEXT[],
    common_phrases TEXT[],
    semantic_field TEXT,
    metadata JSONB DEFAULT '{}',
    date_added TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vocab_search ON vocab_entries USING GIN (word gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_vocab_learning_status ON vocab_entries(learning_status);
CREATE INDEX IF NOT EXISTS idx_vocab_is_mastered ON vocab_entries(is_mastered);

-- =============================================================================
-- TIMELINE & RELATIONS
-- =============================================================================

CREATE TABLE IF NOT EXISTS word_timeline_events (
    id SERIAL PRIMARY KEY,
    vocab_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    century TEXT,
    event_text TEXT NOT NULL,
    sibling_words TEXT[],
    context TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS causal_tags (
    id SERIAL PRIMARY KEY,
    tag_name TEXT UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS timeline_event_tags (
    event_id INTEGER NOT NULL REFERENCES word_timeline_events(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES causal_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (event_id, tag_id)
);

CREATE TABLE IF NOT EXISTS word_relations (
    id SERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    target_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    relation_type TEXT NOT NULL,
    UNIQUE (source_id, target_id, relation_type),
    CHECK (source_id != target_id)
);

CREATE TABLE IF NOT EXISTS root_families (
    id SERIAL PRIMARY KEY,
    root_word TEXT NOT NULL,
    language TEXT NOT NULL,
    meaning TEXT
);

CREATE TABLE IF NOT EXISTS word_root_links (
    vocab_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    root_id INTEGER NOT NULL REFERENCES root_families(id) ON DELETE CASCADE,
    PRIMARY KEY (vocab_id, root_id)
);

-- =============================================================================
-- QUIZ SYSTEM
-- =============================================================================

CREATE TABLE IF NOT EXISTS quiz_materials (
    id SERIAL PRIMARY KEY,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    question_type TEXT NOT NULL,
    prompt TEXT NOT NULL,
    options JSONB,
    correct_answer TEXT,
    variant_data JSONB,
    reward_amount INTEGER DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(word_id, level)
);

CREATE TABLE IF NOT EXISTS user_stats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    silk_balance INTEGER DEFAULT 0,
    words_mastered INTEGER DEFAULT 0,
    words_learned INTEGER DEFAULT 0,
    quizzes_completed INTEGER DEFAULT 0,
    total_health_lost INTEGER DEFAULT 0,
    total_silk_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE TABLE IF NOT EXISTS user_quiz_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    current_level INTEGER DEFAULT 1,
    max_level_reached INTEGER DEFAULT 1,
    health_remaining INTEGER DEFAULT 5,
    silk_earned INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, word_id)
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id SERIAL PRIMARY KEY,
    quiz_id INTEGER REFERENCES user_quiz_progress(id) ON DELETE CASCADE,
    user_id INTEGER,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    is_correct BOOLEAN NOT NULL,
    health_lost INTEGER DEFAULT 0,
    time_taken INTEGER,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- BEAST MODE
-- =============================================================================

CREATE TABLE IF NOT EXISTS beast_mode_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    wager_amount INTEGER NOT NULL CHECK (wager_amount > 0),
    success BOOLEAN NOT NULL,
    silk_earned INTEGER DEFAULT 0,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS beast_mode_cooldowns (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    last_attempt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cooldown_until TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 hour'),
    UNIQUE(user_id, word_id)
);

-- =============================================================================
-- MAPS SYSTEM
-- =============================================================================

CREATE TABLE IF NOT EXISTS maps (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    total_floors INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS floors (
    id SERIAL PRIMARY KEY,
    map_id INTEGER NOT NULL REFERENCES maps(id) ON DELETE CASCADE,
    floor_number INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    unlock_requirement TEXT,
    boss_challenge_type TEXT DEFAULT 'scenario_typing',
    silk_reward INTEGER DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(map_id, floor_number)
);

CREATE TABLE IF NOT EXISTS rooms (
    id SERIAL PRIMARY KEY,
    floor_id INTEGER NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    room_number INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    silk_cost INTEGER DEFAULT 50,
    silk_reward INTEGER DEFAULT 25,
    is_boss_room BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(floor_id, room_number)
);

CREATE TABLE IF NOT EXISTS floor_boss_scenarios (
    id SERIAL PRIMARY KEY,
    floor_id INTEGER NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
    scenario_text TEXT NOT NULL,
    correct_word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    difficulty_level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_map_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    map_id INTEGER NOT NULL REFERENCES maps(id) ON DELETE CASCADE,
    current_floor INTEGER DEFAULT 1,
    current_room INTEGER DEFAULT 1,
    floors_completed INTEGER DEFAULT 0,
    total_silk_spent INTEGER DEFAULT 0,
    total_silk_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, map_id)
);

CREATE TABLE IF NOT EXISTS user_room_unlocks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id INTEGER NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    silk_spent INTEGER DEFAULT 0,
    silk_earned INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, room_id)
);

CREATE TABLE IF NOT EXISTS user_floor_boss_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    floor_id INTEGER NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
    scenarios_presented JSONB,
    user_responses JSONB,
    correct_count INTEGER DEFAULT 0,
    total_scenarios INTEGER DEFAULT 0,
    success BOOLEAN DEFAULT false,
    silk_earned INTEGER DEFAULT 0,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- =============================================================================
-- ADDITIONAL TABLES FROM FULL SCHEMA
-- =============================================================================

CREATE TABLE IF NOT EXISTS citations (
    id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES word_timeline_events(id) ON DELETE CASCADE,
    source TEXT NOT NULL,
    url TEXT,
    quote TEXT,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_citations_event ON citations(event_id);

CREATE TABLE IF NOT EXISTS derivations (
    id SERIAL PRIMARY KEY,
    parent_vocab_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    child_vocab_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    relation_type TEXT NOT NULL,
    notes TEXT,
    UNIQUE (parent_vocab_id, child_vocab_id, relation_type),
    CHECK (parent_vocab_id <> child_vocab_id)
);

CREATE INDEX IF NOT EXISTS idx_derivations_child ON derivations(child_vocab_id);
CREATE INDEX IF NOT EXISTS idx_derivations_parent ON derivations(parent_vocab_id);

CREATE TABLE IF NOT EXISTS purchases (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_id INTEGER REFERENCES tokens(id) ON DELETE CASCADE,
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);

CREATE TABLE IF NOT EXISTS quiz_questions (
    id SERIAL PRIMARY KEY,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    question_type TEXT NOT NULL,
    prompt TEXT NOT NULL,
    options JSONB,
    correct_answer TEXT,
    correct_answers JSONB,
    variant_data JSONB,
    reward_amount INTEGER DEFAULT 10,
    difficulty TEXT DEFAULT 'normal',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(word_id, level)
);

CREATE INDEX IF NOT EXISTS idx_quiz_questions_level ON quiz_questions(level);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_word_id ON quiz_questions(word_id);

CREATE TRIGGER update_quiz_questions_updated_at
BEFORE UPDATE ON quiz_questions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS quizzes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    current_level INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    hard_mode BOOLEAN DEFAULT false,
    wager_amount INTEGER DEFAULT 0,
    hard_mode_completed BOOLEAN DEFAULT false,
    CHECK (current_level >= 1 AND current_level <= 5),
    CHECK (wager_amount >= 0)
);

CREATE INDEX IF NOT EXISTS idx_quizzes_user_id ON quizzes(user_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_word_id ON quizzes(word_id);

CREATE TABLE IF NOT EXISTS semantic_domains (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS silk_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    quiz_id INTEGER REFERENCES quizzes(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    transaction_type TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (transaction_type IN ('earn', 'spend', 'wager_win', 'wager_loss'))
);

CREATE TABLE IF NOT EXISTS tokens (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    silk_cost INTEGER NOT NULL,
    image_url TEXT,
    CHECK (silk_cost >= 0)
);

CREATE TABLE IF NOT EXISTS vocab_domain_links (
    vocab_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    domain_id INTEGER NOT NULL REFERENCES semantic_domains(id) ON DELETE CASCADE,
    PRIMARY KEY (vocab_id, domain_id)
);

CREATE INDEX IF NOT EXISTS idx_vocab_domain_dom ON vocab_domain_links(domain_id);
CREATE INDEX IF NOT EXISTS idx_vocab_domain_vocab ON vocab_domain_links(vocab_id);

-- =============================================================================
-- USER DEFINITIONS & STORY COMPREHENSION
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_word_definitions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    initial_definition TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, word_id)
);

CREATE TABLE IF NOT EXISTS story_comprehension_questions (
    id SERIAL PRIMARY KEY,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    century VARCHAR(10) NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer VARCHAR(255) NOT NULL,
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(word_id, century)
);

CREATE TABLE IF NOT EXISTS user_story_study_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    story_completed BOOLEAN DEFAULT false,
    first_completion_at TIMESTAMP WITH TIME ZONE,
    last_studied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    times_studied INTEGER DEFAULT 0,
    total_silk_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, word_id)
);

CREATE TABLE IF NOT EXISTS user_story_study_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES story_comprehension_questions(id) ON DELETE CASCADE,
    user_answer VARCHAR(255) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_quiz_progress_user_word ON user_quiz_progress(user_id, word_id);
CREATE INDEX IF NOT EXISTS idx_quiz_materials_word_id ON quiz_materials(word_id);
CREATE INDEX IF NOT EXISTS idx_beast_mode_user_word ON beast_mode_cooldowns(user_id, word_id);
CREATE INDEX IF NOT EXISTS idx_maps_user ON user_map_progress(user_id, map_id);
CREATE INDEX IF NOT EXISTS idx_rooms_floor ON rooms(floor_id);
CREATE INDEX IF NOT EXISTS idx_room_unlocks_user ON user_room_unlocks(user_id);
CREATE INDEX IF NOT EXISTS idx_story_questions_word ON story_comprehension_questions(word_id);
CREATE INDEX IF NOT EXISTS idx_user_definitions_user ON user_word_definitions(user_id);

-- =============================================================================
-- TRIGGERS
-- =============================================================================

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER update_user_stats_updated_at
BEFORE UPDATE ON user_stats
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER update_user_quiz_progress_updated_at
BEFORE UPDATE ON user_quiz_progress
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER update_quiz_materials_updated_at
BEFORE UPDATE ON quiz_materials
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER update_user_story_study_progress_updated_at
BEFORE UPDATE ON user_story_study_progress
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- INITIAL DATA
-- =============================================================================

INSERT INTO users (username, password_hash, silk_balance, health_points, max_health_points) 
VALUES ('admin', '$2b$10$placeholder', 0, 3, 3) 
ON CONFLICT DO NOTHING;

INSERT INTO user_stats (user_id, silk_balance)
VALUES (1, 0)
ON CONFLICT DO NOTHING;

