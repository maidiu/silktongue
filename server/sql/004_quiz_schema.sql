-- Quiz System Schema
-- Stores quiz questions, user progress, and rewards

-- Quiz questions table
CREATE TABLE IF NOT EXISTS quiz_questions (
    id SERIAL PRIMARY KEY,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    question_type TEXT NOT NULL, -- 'spelling', 'typing', 'definition', 'syn_ant_sort', 'story_reorder'
    prompt TEXT NOT NULL,
    options JSONB, -- stores different option types depending on question_type
    correct_answer TEXT, -- single correct answer for simple questions
    correct_answers JSONB, -- array of correct answers for multi-select
    variant_data JSONB, -- stores shuffle settings, feedback, hard mode config
    reward_amount INTEGER DEFAULT 10,
    difficulty TEXT DEFAULT 'normal', -- 'normal' or 'hard'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(word_id, level)
);

-- User stats table (tracks silk balance and progress)
CREATE TABLE IF NOT EXISTS user_stats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER, -- placeholder for future auth system
    silk_balance INTEGER DEFAULT 0,
    words_mastered INTEGER DEFAULT 0,
    quizzes_completed INTEGER DEFAULT 0,
    total_health_lost INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User quiz progress table (tracks which quizzes are in progress or completed)
CREATE TABLE IF NOT EXISTS user_quiz_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER, -- placeholder for future auth system
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    current_level INTEGER DEFAULT 1,
    max_level_reached INTEGER DEFAULT 1,
    health_remaining INTEGER DEFAULT 5,
    silk_earned INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, word_id)
);

-- Quiz attempts table (tracks individual level attempts for analytics)
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    success BOOLEAN NOT NULL,
    health_lost INTEGER DEFAULT 0,
    time_taken INTEGER, -- seconds
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_quiz_questions_word_id ON quiz_questions(word_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_level ON quiz_questions(level);
CREATE INDEX IF NOT EXISTS idx_user_quiz_progress_word ON user_quiz_progress(word_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_word ON quiz_attempts(word_id);

-- Insert a default user (id=1) for single-user mode
INSERT INTO user_stats (user_id, silk_balance) 
VALUES (1, 0)
ON CONFLICT DO NOTHING;

-- Add updated_at trigger for quiz_questions
CREATE TRIGGER update_quiz_questions_updated_at
BEFORE UPDATE ON quiz_questions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Add updated_at trigger for user_stats
CREATE TRIGGER update_user_stats_updated_at
BEFORE UPDATE ON user_stats
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Add updated_at trigger for user_quiz_progress
CREATE TRIGGER update_user_quiz_progress_updated_at
BEFORE UPDATE ON user_quiz_progress
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

