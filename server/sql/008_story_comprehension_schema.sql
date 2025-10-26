-- Story Comprehension Questions Schema
CREATE TABLE IF NOT EXISTS story_comprehension_questions (
    id SERIAL PRIMARY KEY,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    century VARCHAR(10) NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of answer options
    correct_answer VARCHAR(255) NOT NULL,
    explanation TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(word_id, century)
);

-- User Story Study Progress
CREATE TABLE IF NOT EXISTS user_story_study_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    story_completed BOOLEAN DEFAULT FALSE,
    first_completion_at TIMESTAMP WITH TIME ZONE,
    last_studied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    times_studied INTEGER DEFAULT 0,
    total_silk_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, word_id)
);

-- User Story Study Attempts (for tracking individual question attempts)
CREATE TABLE IF NOT EXISTS user_story_study_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES story_comprehension_questions(id) ON DELETE CASCADE,
    user_answer VARCHAR(255) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_story_comprehension_word_id ON story_comprehension_questions (word_id);
CREATE INDEX IF NOT EXISTS idx_user_story_study_progress_user_id ON user_story_study_progress (user_id);
CREATE INDEX IF NOT EXISTS idx_user_story_study_progress_word_id ON user_story_study_progress (word_id);
CREATE INDEX IF NOT EXISTS idx_user_story_study_attempts_user_id ON user_story_study_attempts (user_id);
CREATE INDEX IF NOT EXISTS idx_user_story_study_attempts_word_id ON user_story_study_attempts (word_id);
