-- Add just the story_comprehension_questions table for now
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

CREATE INDEX IF NOT EXISTS idx_story_questions_word ON story_comprehension_questions(word_id);

