-- Create table for storing user's initial definitions
CREATE TABLE IF NOT EXISTS user_word_definitions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    initial_definition TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, word_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_word_definitions_user_id ON user_word_definitions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_word_definitions_word_id ON user_word_definitions(word_id);

