-- =============================================================================
-- Vocabulary Knowledge Graph — Full Schema
-- =============================================================================
-- This builds:
--   - Core entries (lexical panel + story fields)
--   - Inter-word relations (synonym/antonym graph)
--   - Dated timeline events (for cross-century analysis)
--   - Causal force tags for events
--   - Root families & links (etymological trees)
--   - Semantic domains (legal, moral, editorial, etc.)
--   - Derivational relations (parent/child morphology)
--   - Citations anchored to specific timeline events
--   - Search helpers (tsvector), indexes, and views
--
-- Conventions:
--   - CENTURY: integer; BCE centuries are negative (e.g., -1 = 1st c. BCE).
--   - exact_date: free-text like 'c. 1400', '1578', '12th–13th c.' for UI.
--   - Keep both denormalized arrays (synonyms_text, antonyms_text) for quick display
--     AND normalized links in word_relations for graph features.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- -----------------------------------------------------------------------------
-- Types
-- -----------------------------------------------------------------------------

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'word_relation_type') THEN
    CREATE TYPE word_relation_type AS ENUM ('synonym','antonym','related','root_sibling');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'derivation_relation_type') THEN
    CREATE TYPE derivation_relation_type AS ENUM ('derives_from','compound_of','borrowed_via','calque_of','affixation','semantic_shift');
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Core table: vocab entries (Lexical Overview + Story anchors)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS vocab_entries (
  id                SERIAL PRIMARY KEY,
  word              TEXT NOT NULL UNIQUE,
  slug              TEXT GENERATED ALWAYS AS (regexp_replace(lower(word), '[^a-z0-9]+', '-', 'g')) STORED,
  part_of_speech    TEXT,                           -- e.g., 'verb', 'adjective'
  modern_definition TEXT,                           -- concise, student-friendly
  usage_example     TEXT,                           -- context-rich sentence
  synonyms_text     TEXT[] DEFAULT '{}',            -- denormalized (quick display)
  antonyms_text     TEXT[] DEFAULT '{}',            -- denormalized (quick display)
  collocations      JSONB DEFAULT '[]',             -- [{"phrase":"lie of omission","gloss":"..."}]
  french_equiv      TEXT,
  russian_equiv     TEXT,
  story_timeline    TEXT,                           -- Markdown (full dated narrative)
  structural_analysis TEXT,                         -- short causal synthesis
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  -- lightweight search vector (you can switch to 'english' config if desired)
  search_vector     tsvector GENERATED ALWAYS AS (
    to_tsvector('simple',
      coalesce(word,'') || ' ' ||
      coalesce(part_of_speech,'') || ' ' ||
      coalesce(modern_definition,'') || ' ' ||
      coalesce(usage_example,'') || ' ' ||
      coalesce(structural_analysis,'')
    )
  ) STORED
);

CREATE INDEX IF NOT EXISTS idx_vocab_entries_slug ON vocab_entries(slug);
CREATE INDEX IF NOT EXISTS idx_vocab_entries_search_vec ON vocab_entries USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS idx_vocab_entries_collocations_gin ON vocab_entries USING GIN (collocations);

-- optional trigger to maintain updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_vocab_entries_updated ON vocab_entries;
CREATE TRIGGER trg_vocab_entries_updated
BEFORE UPDATE ON vocab_entries
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -----------------------------------------------------------------------------
-- Inter-word relations (synonyms / antonyms / related / root_sibling)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS word_relations (
  id          SERIAL PRIMARY KEY,
  source_id   INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  target_id   INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  relation_type word_relation_type NOT NULL,
  note        TEXT,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE (source_id, target_id, relation_type),
  CHECK (source_id <> target_id)
);

CREATE INDEX IF NOT EXISTS idx_word_relations_source ON word_relations(source_id);
CREATE INDEX IF NOT EXISTS idx_word_relations_target ON word_relations(target_id);
CREATE INDEX IF NOT EXISTS idx_word_relations_type   ON word_relations(relation_type);

-- -----------------------------------------------------------------------------
-- Timeline events (dated narrative blocks)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS word_timeline_events (
  id              SERIAL PRIMARY KEY,
  vocab_id        INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  century         INT NOT NULL,             -- negative = BCE (e.g., -1 = 1st c. BCE)
  exact_date      TEXT,                     -- 'c. 1400', '1578', '12th–13th c.'
  language_stage  TEXT,                     -- 'Latin', 'Old French', 'Middle English', etc.
  region          TEXT,                     -- optional: 'Northern France', 'England', etc.
  semantic_focus  TEXT,                     -- tag-ish hint ('moral', 'editorial', 'legal', 'military', etc.)
  event_text      TEXT NOT NULL,            -- the actual dated narrative paragraph
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_timeline_vocab ON word_timeline_events(vocab_id);
CREATE INDEX IF NOT EXISTS idx_timeline_century ON word_timeline_events(century);
CREATE INDEX IF NOT EXISTS idx_timeline_lang ON word_timeline_events(language_stage);
CREATE INDEX IF NOT EXISTS idx_timeline_semantic ON word_timeline_events(semantic_focus);

-- -----------------------------------------------------------------------------
-- Causal forces (tags) and mapping to timeline events
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS causal_tags (
  id          SERIAL PRIMARY KEY,
  tag_name    TEXT UNIQUE NOT NULL,         -- e.g., 'lexical_competition', 'printing_revolution'
  description TEXT
);

CREATE TABLE IF NOT EXISTS timeline_event_tags (
  event_id  INT NOT NULL REFERENCES word_timeline_events(id) ON DELETE CASCADE,
  tag_id    INT NOT NULL REFERENCES causal_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, tag_id)
);

CREATE INDEX IF NOT EXISTS idx_event_tags_event ON timeline_event_tags(event_id);
CREATE INDEX IF NOT EXISTS idx_event_tags_tag   ON timeline_event_tags(tag_id);

-- -----------------------------------------------------------------------------
-- Root families (etymological nodes) and links
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS root_families (
  id         SERIAL PRIMARY KEY,
  root_word  TEXT NOT NULL,                 -- e.g., 'mittere'
  language   TEXT NOT NULL,                 -- e.g., 'Latin'
  gloss      TEXT,
  UNIQUE (root_word, language)
);

CREATE TABLE IF NOT EXISTS word_root_links (
  vocab_id   INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  root_id    INT NOT NULL REFERENCES root_families(id) ON DELETE CASCADE,
  relation_description TEXT,                -- e.g., 'descendant', 'compound of ob- + mittere'
  PRIMARY KEY (vocab_id, root_id)
);

CREATE INDEX IF NOT EXISTS idx_word_root_links_vocab ON word_root_links(vocab_id);
CREATE INDEX IF NOT EXISTS idx_word_root_links_root  ON word_root_links(root_id);

-- -----------------------------------------------------------------------------
-- Semantic domains (legal, moral, editorial, technological...) and links
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS semantic_domains (
  id          SERIAL PRIMARY KEY,
  name        TEXT UNIQUE NOT NULL,         -- e.g., 'legal', 'moral', 'editorial', 'military'
  description TEXT
);

CREATE TABLE IF NOT EXISTS vocab_domain_links (
  vocab_id  INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  domain_id INT NOT NULL REFERENCES semantic_domains(id) ON DELETE CASCADE,
  PRIMARY KEY (vocab_id, domain_id)
);

CREATE INDEX IF NOT EXISTS idx_vocab_domain_vocab ON vocab_domain_links(vocab_id);
CREATE INDEX IF NOT EXISTS idx_vocab_domain_dom   ON vocab_domain_links(domain_id);

-- -----------------------------------------------------------------------------
-- Derivational relations (morphological/etymological parent-child)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS derivations (
  id                 SERIAL PRIMARY KEY,
  parent_vocab_id    INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  child_vocab_id     INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
  relation_type      derivation_relation_type NOT NULL,
  notes              TEXT,
  UNIQUE (parent_vocab_id, child_vocab_id, relation_type),
  CHECK (parent_vocab_id <> child_vocab_id)
);

CREATE INDEX IF NOT EXISTS idx_derivations_parent ON derivations(parent_vocab_id);
CREATE INDEX IF NOT EXISTS idx_derivations_child  ON derivations(child_vocab_id);

-- -----------------------------------------------------------------------------
-- Citations anchored to timeline events (sources, quotes)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS citations (
  id         SERIAL PRIMARY KEY,
  event_id   INT NOT NULL REFERENCES word_timeline_events(id) ON DELETE CASCADE,
  source     TEXT NOT NULL,                 -- 'OED, 3rd ed., entry XYZ', 'Lewis & Short', etc.
  url        TEXT,                          -- optional
  quote      TEXT,                          -- optional quotation/excerpt
  added_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_citations_event ON citations(event_id);

-- -----------------------------------------------------------------------------
-- Helpful views
-- -----------------------------------------------------------------------------

-- View: Global timeline (all events with their word and century)
CREATE OR REPLACE VIEW vw_global_timeline AS
SELECT
  e.id               AS event_id,
  v.id               AS vocab_id,
  v.word,
  e.century,
  e.exact_date,
  e.language_stage,
  e.region,
  e.semantic_focus,
  e.event_text,
  v.part_of_speech
FROM word_timeline_events e
JOIN vocab_entries v ON v.id = e.vocab_id;

-- View: Word relations expanded with words & relation type
CREATE OR REPLACE VIEW vw_word_relations_expanded AS
SELECT
  r.id,
  s.word AS source_word,
  t.word AS target_word,
  r.relation_type,
  r.note,
  r.created_at
FROM word_relations r
JOIN vocab_entries s ON s.id = r.source_id
JOIN vocab_entries t ON t.id = r.target_id;

-- -----------------------------------------------------------------------------
-- Seed some causal tags & semantic domains (optional)
-- -----------------------------------------------------------------------------

INSERT INTO causal_tags (tag_name, description) VALUES
  ('lexical_competition','Shift due to competition within a root family'),
  ('theological_moralization','Sense shaped by religious/moral frameworks'),
  ('bureaucratic_expansion','Administrative/legal textualization'),
  ('printing_revolution','Technological shift to print & editorial precision'),
  ('discursive_specialization','Stabilization in scientific/legal prose'),
  ('fossilization','Older senses preserved only in idioms')
ON CONFLICT (tag_name) DO NOTHING;

INSERT INTO semantic_domains (name, description) VALUES
  ('legal','Law, courts, contracts, administrative codes'),
  ('moral','Ethics, theology, sin/guilt/virtue'),
  ('editorial','Textual acts, print culture, rhetoric'),
  ('military','Fortifications, tactics, logistics'),
  ('scientific','Standardized prose, technical registers'),
  ('bureaucratic','Records, forms, administrative procedure')
ON CONFLICT (name) DO NOTHING;
