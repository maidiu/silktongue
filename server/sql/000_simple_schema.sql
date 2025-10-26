-- Simple schema that matches the API routes
-- Drop existing table if needed
DROP TABLE IF EXISTS vocab_entries CASCADE;

-- Create vocab_entries table
CREATE TABLE vocab_entries (
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
  date_added TIMESTAMP DEFAULT NOW(),
  
  -- Fields for detailed view
  story_text TEXT,
  contrastive_opening TEXT,
  structural_analysis TEXT
);

-- Create supporting tables for detailed view
CREATE TABLE IF NOT EXISTS word_timeline_events (
  id SERIAL PRIMARY KEY,
  vocab_entry_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  century TEXT,
  year INT,
  sense_at_time TEXT,
  sibling_words TEXT[],
  cultural_context TEXT,
  causal_tensions TEXT,
  language_transitions TEXT,
  event_text TEXT NOT NULL,
  sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS causal_tags (
  id SERIAL PRIMARY KEY,
  tag_name TEXT UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE IF NOT EXISTS timeline_event_tags (
  event_id INT NOT NULL REFERENCES word_timeline_events(id) ON DELETE CASCADE,
  tag_id INT NOT NULL REFERENCES causal_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, tag_id)
);

CREATE TABLE IF NOT EXISTS word_relations (
  id SERIAL PRIMARY KEY,
  vocab_entry_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  related_word_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  relation_type TEXT NOT NULL,
  UNIQUE (vocab_entry_id, related_word_id, relation_type)
);

CREATE TABLE IF NOT EXISTS root_families (
  id SERIAL PRIMARY KEY,
  root_word TEXT NOT NULL,
  language TEXT NOT NULL,
  meaning TEXT,
  UNIQUE (root_word, language)
);

CREATE TABLE IF NOT EXISTS word_root_links (
  vocab_entry_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  root_id INT NOT NULL REFERENCES root_families(id) ON DELETE CASCADE,
  PRIMARY KEY (vocab_entry_id, root_id)
);

-- Insert some sample data
INSERT INTO vocab_entries (word, part_of_speech, modern_definition, usage_example, is_mastered)
VALUES 
  ('omission', 'noun', 'The act of leaving something out or failing to include it', 'The omission of key details made the report incomplete', false),
  ('suppress', 'verb', 'To forcibly put an end to or prevent from being revealed', 'The government tried to suppress information about the scandal', false),
  ('commission', 'noun', 'A formal group or authority charged with a specific task', 'The ethics commission investigated the allegations', false)
ON CONFLICT (word) DO NOTHING;

