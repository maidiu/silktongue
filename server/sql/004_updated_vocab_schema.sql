-- ==========================================================
--  ENUMS
-- ==========================================================
CREATE TYPE word_relation_type AS ENUM ('synonym', 'antonym', 'related');

-- ==========================================================
--  CORE TABLES
-- ==========================================================

-- -------------------------
--  vocab_entries
-- -------------------------
CREATE TABLE IF NOT EXISTS public.vocab_entries (
    id SERIAL PRIMARY KEY,
    word TEXT UNIQUE NOT NULL,
    part_of_speech TEXT,
    modern_definition TEXT,
    usage_example TEXT,
    common_collocations TEXT[],
    french_equiv TEXT,
    russian_equiv TEXT,
    structural_analysis TEXT,
    is_mastered BOOLEAN DEFAULT FALSE,
    date_added TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- -------------------------
--  word_timeline_events
-- -------------------------
CREATE TABLE IF NOT EXISTS public.word_timeline_events (
    id SERIAL PRIMARY KEY,
    vocab_entry_id INT REFERENCES vocab_entries(id) ON DELETE CASCADE,
    century TEXT,
    century_int SMALLINT GENERATED ALWAYS AS (
        NULLIF(regexp_replace(century, '[^0-9-]', '', 'g'), '')::smallint
    ) STORED,
    centuries TEXT[] GENERATED ALWAYS AS (
        string_to_array(replace(century, '–', '-'), '-')
    ) STORED,
    story_text TEXT,
    sibling_words TEXT[],
    context TEXT
);

-- -------------------------
--  causal_tags
-- -------------------------
CREATE TABLE IF NOT EXISTS public.causal_tags (
    id SERIAL PRIMARY KEY,
    tag_name TEXT UNIQUE NOT NULL
);

-- -------------------------
--  timeline_event_tags
-- -------------------------
CREATE TABLE IF NOT EXISTS public.timeline_event_tags (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES word_timeline_events(id) ON DELETE CASCADE,
    tag_id INT REFERENCES causal_tags(id) ON DELETE CASCADE,
    UNIQUE (event_id, tag_id)
);

-- -------------------------
--  word_relations
-- -------------------------
CREATE TABLE IF NOT EXISTS public.word_relations (
    id SERIAL PRIMARY KEY,
    source_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    target_id INT NOT NULL REFERENCES vocab_entries(id) ON DELETE CASCADE,
    relation_type word_relation_type NOT NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT word_relations_source_id_target_id_relation_type_key
        UNIQUE (source_id, target_id, relation_type),
    CONSTRAINT word_relations_check CHECK (source_id <> target_id)
);

-- -------------------------
--  root_families
-- -------------------------
CREATE TABLE IF NOT EXISTS public.root_families (
    id SERIAL PRIMARY KEY,
    root_name TEXT UNIQUE NOT NULL,
    language_origin TEXT,
    gloss TEXT
);

-- -------------------------
--  word_root_links
-- -------------------------
CREATE TABLE IF NOT EXISTS public.word_root_links (
    id SERIAL PRIMARY KEY,
    vocab_entry_id INT REFERENCES vocab_entries(id) ON DELETE CASCADE,
    root_id INT REFERENCES root_families(id) ON DELETE CASCADE,
    UNIQUE (vocab_entry_id, root_id)
);

-- -------------------------
--  semantic_domains
-- -------------------------
CREATE TABLE IF NOT EXISTS public.semantic_domains (
    id SERIAL PRIMARY KEY,
    domain_name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- -------------------------
--  vocab_domain_links
-- -------------------------
CREATE TABLE IF NOT EXISTS public.vocab_domain_links (
    id SERIAL PRIMARY KEY,
    vocab_entry_id INT REFERENCES vocab_entries(id) ON DELETE CASCADE,
    domain_id INT REFERENCES semantic_domains(id) ON DELETE CASCADE,
    UNIQUE (vocab_entry_id, domain_id)
);

-- -------------------------
--  derivations
-- -------------------------
CREATE TABLE IF NOT EXISTS public.derivations (
    id SERIAL PRIMARY KEY,
    parent_id INT REFERENCES vocab_entries(id) ON DELETE CASCADE,
    child_id INT REFERENCES vocab_entries(id) ON DELETE CASCADE,
    derivation_note TEXT,
    UNIQUE (parent_id, child_id)
);

-- -------------------------
--  citations
-- -------------------------
CREATE TABLE IF NOT EXISTS public.citations (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES word_timeline_events(id) ON DELETE CASCADE,
    source_title TEXT,
    author TEXT,
    year TEXT,
    excerpt TEXT,
    note TEXT
);

-- ==========================================================
--  INDEXES
-- ==========================================================
CREATE INDEX IF NOT EXISTS idx_vocab_word
    ON public.vocab_entries USING GIN (to_tsvector('english', word));

CREATE INDEX IF NOT EXISTS idx_vocab_definition
    ON public.vocab_entries USING GIN (to_tsvector('english', modern_definition));

CREATE INDEX IF NOT EXISTS idx_timeline_story
    ON public.word_timeline_events USING GIN (to_tsvector('english', story_text));

CREATE INDEX IF NOT EXISTS idx_timeline_century
    ON public.word_timeline_events (century);

CREATE INDEX IF NOT EXISTS idx_timeline_century_int
    ON public.word_timeline_events (century_int);

CREATE INDEX IF NOT EXISTS idx_timeline_centuries
    ON public.word_timeline_events USING GIN (centuries);

CREATE INDEX IF NOT EXISTS idx_word_relations_source
    ON public.word_relations (source_id);

CREATE INDEX IF NOT EXISTS idx_word_relations_target
    ON public.word_relations (target_id);

CREATE INDEX IF NOT EXISTS idx_word_relations_type
    ON public.word_relations (relation_type);

-- ==========================================================
--  VIEWS
-- ==========================================================
CREATE OR REPLACE VIEW century_summary AS
SELECT
  century,
  COUNT(DISTINCT wte.vocab_entry_id) AS word_count,
  COUNT(*) AS event_count
FROM word_timeline_events wte
GROUP BY century
ORDER BY century;

-- ==========================================================
--  EXTENSIONS
-- ==========================================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
