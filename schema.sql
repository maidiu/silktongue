--
-- PostgreSQL database dump
--

\restrict RgsDT0tjo3lb7lTrdwXQp6z1ExSQW7yvyn0KBgBiddXyJkOgEdqHMi6hw7vEXcx

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.14 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: derivation_relation_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.derivation_relation_type AS ENUM (
    'derives_from',
    'compound_of',
    'borrowed_via',
    'calque_of',
    'affixation',
    'semantic_shift'
);


ALTER TYPE public.derivation_relation_type OWNER TO postgres;

--
-- Name: word_relation_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.word_relation_type AS ENUM (
    'synonym',
    'antonym',
    'related',
    'root_sibling'
);


ALTER TYPE public.word_relation_type OWNER TO postgres;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: causal_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.causal_tags (
    id integer NOT NULL,
    tag_name text NOT NULL,
    description text
);


ALTER TABLE public.causal_tags OWNER TO postgres;

--
-- Name: causal_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.causal_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.causal_tags_id_seq OWNER TO postgres;

--
-- Name: causal_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.causal_tags_id_seq OWNED BY public.causal_tags.id;


--
-- Name: word_timeline_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.word_timeline_events (
    id integer NOT NULL,
    vocab_id integer NOT NULL,
    century integer NOT NULL,
    exact_date text,
    language_stage text,
    region text,
    semantic_focus text,
    event_text text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    sibling_words text[],
    context text
);


ALTER TABLE public.word_timeline_events OWNER TO postgres;

--
-- Name: century_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.century_summary AS
 SELECT word_timeline_events.century,
    count(DISTINCT word_timeline_events.vocab_id) AS word_count,
    count(*) AS event_count
   FROM public.word_timeline_events
  GROUP BY word_timeline_events.century
  ORDER BY word_timeline_events.century;


ALTER TABLE public.century_summary OWNER TO postgres;

--
-- Name: citations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citations (
    id integer NOT NULL,
    event_id integer NOT NULL,
    source text NOT NULL,
    url text,
    quote text,
    added_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.citations OWNER TO postgres;

--
-- Name: citations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.citations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.citations_id_seq OWNER TO postgres;

--
-- Name: citations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.citations_id_seq OWNED BY public.citations.id;


--
-- Name: derivations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.derivations (
    id integer NOT NULL,
    parent_vocab_id integer NOT NULL,
    child_vocab_id integer NOT NULL,
    relation_type public.derivation_relation_type NOT NULL,
    notes text,
    CONSTRAINT derivations_check CHECK ((parent_vocab_id <> child_vocab_id))
);


ALTER TABLE public.derivations OWNER TO postgres;

--
-- Name: derivations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.derivations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.derivations_id_seq OWNER TO postgres;

--
-- Name: derivations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.derivations_id_seq OWNED BY public.derivations.id;


--
-- Name: root_families; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.root_families (
    id integer NOT NULL,
    root_word text NOT NULL,
    language text NOT NULL,
    gloss text
);


ALTER TABLE public.root_families OWNER TO postgres;

--
-- Name: root_families_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.root_families_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.root_families_id_seq OWNER TO postgres;

--
-- Name: root_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.root_families_id_seq OWNED BY public.root_families.id;


--
-- Name: semantic_domains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.semantic_domains (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.semantic_domains OWNER TO postgres;

--
-- Name: semantic_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.semantic_domains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.semantic_domains_id_seq OWNER TO postgres;

--
-- Name: semantic_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.semantic_domains_id_seq OWNED BY public.semantic_domains.id;


--
-- Name: timeline_event_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.timeline_event_tags (
    event_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.timeline_event_tags OWNER TO postgres;

--
-- Name: vocab_domain_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vocab_domain_links (
    vocab_id integer NOT NULL,
    domain_id integer NOT NULL
);


ALTER TABLE public.vocab_domain_links OWNER TO postgres;

--
-- Name: vocab_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vocab_entries (
    id integer NOT NULL,
    word text NOT NULL,
    part_of_speech text,
    modern_definition text,
    usage_example text,
    synonyms text[],
    antonyms text[],
    collocations jsonb DEFAULT '{}'::jsonb,
    french_equivalent text,
    russian_equivalent text,
    cefr_level text,
    pronunciation text,
    is_mastered boolean DEFAULT false,
    date_added timestamp without time zone DEFAULT now(),
    story_text text,
    contrastive_opening text,
    structural_analysis text,
    common_collocations text[],
    metadata jsonb,
    definitions jsonb,
    variant_forms text[],
    semantic_field text[],
    english_synonyms text[],
    english_antonyms text[],
    french_synonyms text[],
    french_root_cognates text[],
    russian_synonyms text[],
    russian_root_cognates text[],
    common_phrases text[],
);


ALTER TABLE public.vocab_entries OWNER TO postgres;

--
-- Name: vocab_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vocab_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vocab_entries_id_seq OWNER TO postgres;

--
-- Name: vocab_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vocab_entries_id_seq OWNED BY public.vocab_entries.id;


--
-- Name: word_relations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.word_relations (
    id integer NOT NULL,
    source_id integer NOT NULL,
    target_id integer NOT NULL,
    relation_type public.word_relation_type NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT word_relations_check CHECK ((source_id <> target_id))
);


ALTER TABLE public.word_relations OWNER TO postgres;

--
-- Name: word_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.word_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.word_relations_id_seq OWNER TO postgres;

--
-- Name: word_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.word_relations_id_seq OWNED BY public.word_relations.id;


--
-- Name: word_root_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.word_root_links (
    vocab_id integer NOT NULL,
    root_id integer NOT NULL,
    relation_description text
);


ALTER TABLE public.word_root_links OWNER TO postgres;

--
-- Name: word_timeline_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.word_timeline_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.word_timeline_events_id_seq OWNER TO postgres;

--
-- Name: word_timeline_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.word_timeline_events_id_seq OWNED BY public.word_timeline_events.id;


--
-- Name: causal_tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.causal_tags ALTER COLUMN id SET DEFAULT nextval('public.causal_tags_id_seq'::regclass);


--
-- Name: citations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citations ALTER COLUMN id SET DEFAULT nextval('public.citations_id_seq'::regclass);


--
-- Name: derivations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.derivations ALTER COLUMN id SET DEFAULT nextval('public.derivations_id_seq'::regclass);


--
-- Name: root_families id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.root_families ALTER COLUMN id SET DEFAULT nextval('public.root_families_id_seq'::regclass);


--
-- Name: semantic_domains id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semantic_domains ALTER COLUMN id SET DEFAULT nextval('public.semantic_domains_id_seq'::regclass);


--
-- Name: vocab_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vocab_entries ALTER COLUMN id SET DEFAULT nextval('public.vocab_entries_id_seq'::regclass);


--
-- Name: word_relations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_relations ALTER COLUMN id SET DEFAULT nextval('public.word_relations_id_seq'::regclass);


--
-- Name: word_timeline_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_timeline_events ALTER COLUMN id SET DEFAULT nextval('public.word_timeline_events_id_seq'::regclass);


--
-- Name: causal_tags causal_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.causal_tags
    ADD CONSTRAINT causal_tags_pkey PRIMARY KEY (id);


--
-- Name: causal_tags causal_tags_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.causal_tags
    ADD CONSTRAINT causal_tags_tag_name_key UNIQUE (tag_name);


--
-- Name: citations citations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citations
    ADD CONSTRAINT citations_pkey PRIMARY KEY (id);


--
-- Name: derivations derivations_parent_vocab_id_child_vocab_id_relation_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.derivations
    ADD CONSTRAINT derivations_parent_vocab_id_child_vocab_id_relation_type_key UNIQUE (parent_vocab_id, child_vocab_id, relation_type);


--
-- Name: derivations derivations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.derivations
    ADD CONSTRAINT derivations_pkey PRIMARY KEY (id);


--
-- Name: root_families root_families_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.root_families
    ADD CONSTRAINT root_families_pkey PRIMARY KEY (id);


--
-- Name: root_families root_families_root_word_language_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.root_families
    ADD CONSTRAINT root_families_root_word_language_key UNIQUE (root_word, language);


--
-- Name: semantic_domains semantic_domains_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semantic_domains
    ADD CONSTRAINT semantic_domains_name_key UNIQUE (name);


--
-- Name: semantic_domains semantic_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semantic_domains
    ADD CONSTRAINT semantic_domains_pkey PRIMARY KEY (id);


--
-- Name: timeline_event_tags timeline_event_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeline_event_tags
    ADD CONSTRAINT timeline_event_tags_pkey PRIMARY KEY (event_id, tag_id);


--
-- Name: vocab_domain_links vocab_domain_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vocab_domain_links
    ADD CONSTRAINT vocab_domain_links_pkey PRIMARY KEY (vocab_id, domain_id);


--
-- Name: vocab_entries vocab_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vocab_entries
    ADD CONSTRAINT vocab_entries_pkey PRIMARY KEY (id);


--
-- Name: vocab_entries vocab_entries_word_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vocab_entries
    ADD CONSTRAINT vocab_entries_word_key UNIQUE (word);


--
-- Name: word_relations word_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_relations
    ADD CONSTRAINT word_relations_pkey PRIMARY KEY (id);


--
-- Name: word_relations word_relations_source_id_target_id_relation_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_relations
    ADD CONSTRAINT word_relations_source_id_target_id_relation_type_key UNIQUE (source_id, target_id, relation_type);


--
-- Name: word_root_links word_root_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_root_links
    ADD CONSTRAINT word_root_links_pkey PRIMARY KEY (vocab_id, root_id);


--
-- Name: word_timeline_events word_timeline_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_timeline_events
    ADD CONSTRAINT word_timeline_events_pkey PRIMARY KEY (id);


--
-- Name: idx_citations_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_citations_event ON public.citations USING btree (event_id);


--
-- Name: idx_derivations_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_derivations_child ON public.derivations USING btree (child_vocab_id);


--
-- Name: idx_derivations_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_derivations_parent ON public.derivations USING btree (parent_vocab_id);


--
-- Name: idx_event_tags_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_tags_event ON public.timeline_event_tags USING btree (event_id);


--
-- Name: idx_event_tags_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_tags_tag ON public.timeline_event_tags USING btree (tag_id);


--
-- Name: idx_timeline_century; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeline_century ON public.word_timeline_events USING btree (century);


--
-- Name: idx_timeline_lang; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeline_lang ON public.word_timeline_events USING btree (language_stage);


--
-- Name: idx_timeline_semantic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeline_semantic ON public.word_timeline_events USING btree (semantic_focus);


--
-- Name: idx_timeline_vocab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeline_vocab ON public.word_timeline_events USING btree (vocab_id);


--
-- Name: idx_vocab_domain_dom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vocab_domain_dom ON public.vocab_domain_links USING btree (domain_id);


--
-- Name: idx_vocab_domain_vocab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vocab_domain_vocab ON public.vocab_domain_links USING btree (vocab_id);


--
-- Name: idx_word_relations_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_word_relations_source ON public.word_relations USING btree (source_id);


--
-- Name: idx_word_relations_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_word_relations_target ON public.word_relations USING btree (target_id);


--
-- Name: idx_word_relations_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_word_relations_type ON public.word_relations USING btree (relation_type);


--
-- Name: idx_word_root_links_root; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_word_root_links_root ON public.word_root_links USING btree (root_id);


--
-- Name: idx_word_root_links_vocab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_word_root_links_vocab ON public.word_root_links USING btree (vocab_id);


--
-- Name: vocab_definitions_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vocab_definitions_idx ON public.vocab_entries USING gin (definitions);


--
-- Name: vocab_long_story_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vocab_long_story_idx ON public.vocab_entries USING gin (to_tsvector('english'::regconfig, long_story));


--
-- Name: citations citations_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citations
    ADD CONSTRAINT citations_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.word_timeline_events(id) ON DELETE CASCADE;


--
-- Name: timeline_event_tags timeline_event_tags_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeline_event_tags
    ADD CONSTRAINT timeline_event_tags_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.word_timeline_events(id) ON DELETE CASCADE;


--
-- Name: timeline_event_tags timeline_event_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeline_event_tags
    ADD CONSTRAINT timeline_event_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.causal_tags(id) ON DELETE CASCADE;


--
-- Name: vocab_domain_links vocab_domain_links_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vocab_domain_links
    ADD CONSTRAINT vocab_domain_links_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.semantic_domains(id) ON DELETE CASCADE;


--
-- Name: word_root_links word_root_links_root_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.word_root_links
    ADD CONSTRAINT word_root_links_root_id_fkey FOREIGN KEY (root_id) REFERENCES public.root_families(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict RgsDT0tjo3lb7lTrdwXQp6z1ExSQW7yvyn0KBgBiddXyJkOgEdqHMi6hw7vEXcx



-- =========================================================
-- 🧠 USER ECONOMY AND QUIZ SYSTEM TABLES
-- =========================================================

-- 1️⃣ USERS
CREATE TABLE IF NOT EXISTS public.users (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    silk_balance INTEGER DEFAULT 0 CHECK (silk_balance >= 0),
    health_points INTEGER DEFAULT 5 CHECK (health_points >= 0),
    last_health_reset TIMESTAMP DEFAULT now()
);

-- 2️⃣ QUIZZES (per word per user)
CREATE TABLE IF NOT EXISTS public.quizzes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES public.users(id) ON DELETE CASCADE,
    word_id INTEGER REFERENCES public.vocab_entries(id) ON DELETE CASCADE,
    current_level INTEGER DEFAULT 1 CHECK (current_level >= 1 AND current_level <= 5),
    is_active BOOLEAN DEFAULT true,
    started_at TIMESTAMP DEFAULT now(),
    completed_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_quizzes_user_id ON public.quizzes (user_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_word_id ON public.quizzes (word_id);

-- 3️⃣ QUIZ ATTEMPTS (track individual tries)
CREATE TABLE IF NOT EXISTS public.quiz_attempts (
    id SERIAL PRIMARY KEY,
    quiz_id INTEGER REFERENCES public.quizzes(id) ON DELETE CASCADE,
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    is_success BOOLEAN DEFAULT false,
    attempt_data JSONB,
    attempted_at TIMESTAMP DEFAULT now()
);

-- 4️⃣ SILK TRANSACTIONS (track earnings/spending)
CREATE TABLE IF NOT EXISTS public.silk_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES public.users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    transaction_type TEXT CHECK (transaction_type IN ('earn', 'spend', 'adjust')),
    reason TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_silk_transactions_user_id
    ON public.silk_transactions (user_id);

-- 5️⃣ QUIZ MATERIALS (core question/answer dataset)
CREATE TABLE IF NOT EXISTS public.quiz_materials (
    id SERIAL PRIMARY KEY,
    word_id INTEGER REFERENCES public.vocab_entries(id) ON DELETE CASCADE,
    level INTEGER CHECK (level BETWEEN 1 AND 5),
    question_type TEXT CHECK (question_type IN ('spelling', 'typing', 'definition', 'synonym', 'antonym', 'story')),
    prompt TEXT,
    options JSONB,
    correct_answer TEXT,
    variant_data JSONB,
    reward_amount INTEGER DEFAULT 10,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_quiz_materials_word_level
    ON public.quiz_materials (word_id, level);

-- 6️⃣ LEADERBOARD (aggregated stats)
CREATE TABLE IF NOT EXISTS public.leaderboard (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES public.users(id) ON DELETE CASCADE,
    total_silk INTEGER DEFAULT 0,
    words_mastered INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT now()
);
