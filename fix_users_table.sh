#!/bin/bash
# Add missing columns to users and root_families tables

cd /var/www/maxvocab

sudo -u postgres psql -d vocab_atlas << 'SQL'
-- Fix users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS words_learned INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS words_mastered INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_silk_earned INTEGER DEFAULT 0;

-- Fix root_families table (add gloss column or rename meaning to gloss)
ALTER TABLE root_families ADD COLUMN IF NOT EXISTS gloss TEXT;
UPDATE root_families SET gloss = meaning WHERE gloss IS NULL AND meaning IS NOT NULL;
ALTER TABLE root_families DROP COLUMN IF EXISTS meaning;

SELECT 'Tables fixed!' AS status;
SQL

