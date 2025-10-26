-- Beast Mode Schema
-- Adds wager system and cooldown tracking

-- Beast mode attempts table
CREATE TABLE IF NOT EXISTS beast_mode_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    wager_amount INTEGER NOT NULL CHECK (wager_amount > 0),
    success BOOLEAN NOT NULL,
    silk_earned INTEGER DEFAULT 0,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Beast mode cooldowns table
CREATE TABLE IF NOT EXISTS beast_mode_cooldowns (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    word_id INTEGER REFERENCES vocab_entries(id) ON DELETE CASCADE,
    last_attempt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cooldown_until TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 hour'),
    UNIQUE(user_id, word_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_beast_attempts_user ON beast_mode_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_beast_attempts_word ON beast_mode_attempts(word_id);
CREATE INDEX IF NOT EXISTS idx_beast_cooldowns_user ON beast_mode_cooldowns(user_id);
CREATE INDEX IF NOT EXISTS idx_beast_cooldowns_word ON beast_mode_cooldowns(word_id);

-- Add updated_at trigger for beast_mode_attempts
CREATE TRIGGER update_beast_mode_attempts_updated_at
BEFORE UPDATE ON beast_mode_attempts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
