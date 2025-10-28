--
-- PostgreSQL database dump
--

\restrict TSTH1u4fj81NmlEa0a762FKs9bHnYeG0z14reeu9ikddiCycF06Xl0aUPiNFbtx

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
-- Name: beast_mode_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beast_mode_attempts (
    id integer NOT NULL,
    user_id integer,
    word_id integer,
    wager_amount integer NOT NULL,
    success boolean NOT NULL,
    silk_earned integer DEFAULT 0,
    attempted_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT beast_mode_attempts_wager_amount_check CHECK ((wager_amount > 0))
);


ALTER TABLE public.beast_mode_attempts OWNER TO postgres;

--
-- Name: beast_mode_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.beast_mode_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.beast_mode_attempts_id_seq OWNER TO postgres;

--
-- Name: beast_mode_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.beast_mode_attempts_id_seq OWNED BY public.beast_mode_attempts.id;


--
-- Name: beast_mode_cooldowns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beast_mode_cooldowns (
    id integer NOT NULL,
    user_id integer,
    word_id integer,
    last_attempt timestamp with time zone DEFAULT now(),
    cooldown_until timestamp with time zone DEFAULT (now() + '01:00:00'::interval)
);


ALTER TABLE public.beast_mode_cooldowns OWNER TO postgres;

--
-- Name: beast_mode_cooldowns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.beast_mode_cooldowns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.beast_mode_cooldowns_id_seq OWNER TO postgres;

--
-- Name: beast_mode_cooldowns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.beast_mode_cooldowns_id_seq OWNED BY public.beast_mode_cooldowns.id;


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
-- Name: floor_boss_scenarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floor_boss_scenarios (
    id integer NOT NULL,
    floor_id integer,
    scenario_text text NOT NULL,
    correct_word_id integer,
    difficulty_level integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.floor_boss_scenarios OWNER TO postgres;

--
-- Name: floor_boss_scenarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.floor_boss_scenarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.floor_boss_scenarios_id_seq OWNER TO postgres;

--
-- Name: floor_boss_scenarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.floor_boss_scenarios_id_seq OWNED BY public.floor_boss_scenarios.id;


--
-- Name: floors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floors (
    id integer NOT NULL,
    map_id integer,
    floor_number integer NOT NULL,
    name text NOT NULL,
    description text,
    unlock_requirement text,
    boss_challenge_type text DEFAULT 'scenario_typing'::text,
    silk_reward integer DEFAULT 100,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.floors OWNER TO postgres;

--
-- Name: floors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.floors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.floors_id_seq OWNER TO postgres;

--
-- Name: floors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.floors_id_seq OWNED BY public.floors.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    silk_balance integer DEFAULT 0,
    health_points integer DEFAULT 5,
    last_health_reset timestamp without time zone DEFAULT now(),
    words_learned integer DEFAULT 0,
    words_mastered integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    is_admin boolean DEFAULT false,
    max_health_points integer DEFAULT 3,
    avatar_config jsonb DEFAULT '{"body": "hornet", "mask": "hornet", "wings": "silk", "weapon": "needle", "effects": ["sparkle"], "accentColor": "#ff6b6b", "primaryColor": "#2d1b2d", "secondaryColor": "#4a2c4a"}'::jsonb,
    CONSTRAINT users_health_points_check CHECK ((health_points >= 0)),
    CONSTRAINT users_max_health_points_check CHECK (((max_health_points >= 3) AND (max_health_points <= 6))),
    CONSTRAINT users_silk_balance_check CHECK ((silk_balance >= 0))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: leaderboard; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.leaderboard AS
 SELECT users.username,
    users.silk_balance,
    users.health_points,
    rank() OVER (ORDER BY users.silk_balance DESC) AS rank
   FROM public.users;


ALTER TABLE public.leaderboard OWNER TO postgres;

--
-- Name: maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maps (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    total_floors integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.maps OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.maps_id_seq OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maps_id_seq OWNED BY public.maps.id;


--
-- Name: purchases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchases (
    id integer NOT NULL,
    user_id integer,
    token_id integer,
    purchased_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.purchases OWNER TO postgres;

--
-- Name: purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchases_id_seq OWNER TO postgres;

--
-- Name: purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchases_id_seq OWNED BY public.purchases.id;


--
-- Name: quiz_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_attempts (
    id integer NOT NULL,
    quiz_id integer,
    level integer NOT NULL,
    is_correct boolean,
    attempted_at timestamp without time zone DEFAULT now(),
    CONSTRAINT quiz_attempts_level_check CHECK (((level >= 1) AND (level <= 6)))
);


ALTER TABLE public.quiz_attempts OWNER TO postgres;

--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quiz_attempts_id_seq OWNER TO postgres;

--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_attempts_id_seq OWNED BY public.quiz_attempts.id;


--
-- Name: quiz_materials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_materials (
    id integer NOT NULL,
    word_id integer,
    level integer,
    question_type text,
    prompt text,
    options jsonb,
    correct_answer text,
    variant_data jsonb,
    reward_amount integer DEFAULT 10,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT quiz_materials_level_check CHECK (((level >= 1) AND (level <= 6))),
    CONSTRAINT quiz_materials_question_type_check CHECK ((question_type = ANY (ARRAY['spelling'::text, 'typing'::text, 'definition'::text, 'synonym'::text, 'antonym'::text, 'story'::text, 'story_reorder'::text, 'syn_ant_sort'::text])))
);


ALTER TABLE public.quiz_materials OWNER TO postgres;

--
-- Name: quiz_materials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quiz_materials_id_seq OWNER TO postgres;

--
-- Name: quiz_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_materials_id_seq OWNED BY public.quiz_materials.id;


--
-- Name: quiz_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_questions (
    id integer NOT NULL,
    word_id integer,
    level integer NOT NULL,
    question_type text NOT NULL,
    prompt text NOT NULL,
    options jsonb,
    correct_answer text,
    correct_answers jsonb,
    variant_data jsonb,
    reward_amount integer DEFAULT 10,
    difficulty text DEFAULT 'normal'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.quiz_questions OWNER TO postgres;

--
-- Name: quiz_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quiz_questions_id_seq OWNER TO postgres;

--
-- Name: quiz_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_questions_id_seq OWNED BY public.quiz_questions.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quizzes (
    id integer NOT NULL,
    user_id integer,
    word_id integer,
    current_level integer DEFAULT 1,
    is_active boolean DEFAULT true,
    started_at timestamp without time zone DEFAULT now(),
    completed_at timestamp without time zone,
    hard_mode boolean DEFAULT false,
    wager_amount integer DEFAULT 0,
    hard_mode_completed boolean DEFAULT false,
    CONSTRAINT quizzes_current_level_check CHECK (((current_level >= 1) AND (current_level <= 5))),
    CONSTRAINT quizzes_wager_amount_check CHECK ((wager_amount >= 0))
);


ALTER TABLE public.quizzes OWNER TO postgres;

--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quizzes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quizzes_id_seq OWNER TO postgres;

--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quizzes_id_seq OWNED BY public.quizzes.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    floor_id integer,
    word_id integer,
    room_number integer NOT NULL,
    name text NOT NULL,
    description text,
    silk_cost integer DEFAULT 50,
    silk_reward integer DEFAULT 25,
    is_boss_room boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rooms_id_seq OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


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
-- Name: silk_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.silk_transactions (
    id integer NOT NULL,
    user_id integer,
    quiz_id integer,
    amount integer NOT NULL,
    transaction_type text,
    description text,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT silk_transactions_transaction_type_check CHECK ((transaction_type = ANY (ARRAY['earn'::text, 'spend'::text, 'wager_win'::text, 'wager_loss'::text])))
);


ALTER TABLE public.silk_transactions OWNER TO postgres;

--
-- Name: silk_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.silk_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.silk_transactions_id_seq OWNER TO postgres;

--
-- Name: silk_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.silk_transactions_id_seq OWNED BY public.silk_transactions.id;


--
-- Name: story_comprehension_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.story_comprehension_questions (
    id integer NOT NULL,
    word_id integer NOT NULL,
    century character varying(10) NOT NULL,
    question text NOT NULL,
    options jsonb NOT NULL,
    correct_answer character varying(255) NOT NULL,
    explanation text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.story_comprehension_questions OWNER TO postgres;

--
-- Name: story_comprehension_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.story_comprehension_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.story_comprehension_questions_id_seq OWNER TO postgres;

--
-- Name: story_comprehension_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.story_comprehension_questions_id_seq OWNED BY public.story_comprehension_questions.id;


--
-- Name: timeline_event_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.timeline_event_tags (
    event_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.timeline_event_tags OWNER TO postgres;

--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    silk_cost integer NOT NULL,
    image_url text,
    CONSTRAINT tokens_silk_cost_check CHECK ((silk_cost >= 0))
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tokens_id_seq OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: user_floor_boss_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_floor_boss_attempts (
    id integer NOT NULL,
    user_id integer,
    floor_id integer,
    scenarios_presented jsonb,
    user_responses jsonb,
    correct_count integer DEFAULT 0,
    total_scenarios integer DEFAULT 0,
    success boolean DEFAULT false,
    silk_earned integer DEFAULT 0,
    attempted_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone
);


ALTER TABLE public.user_floor_boss_attempts OWNER TO postgres;

--
-- Name: user_floor_boss_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_floor_boss_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_floor_boss_attempts_id_seq OWNER TO postgres;

--
-- Name: user_floor_boss_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_floor_boss_attempts_id_seq OWNED BY public.user_floor_boss_attempts.id;


--
-- Name: user_map_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_map_progress (
    id integer NOT NULL,
    user_id integer,
    map_id integer,
    current_floor integer DEFAULT 1,
    current_room integer DEFAULT 1,
    floors_completed integer DEFAULT 0,
    total_silk_spent integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_map_progress OWNER TO postgres;

--
-- Name: user_map_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_map_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_map_progress_id_seq OWNER TO postgres;

--
-- Name: user_map_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_map_progress_id_seq OWNED BY public.user_map_progress.id;


--
-- Name: user_quiz_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_quiz_progress (
    id integer NOT NULL,
    user_id integer,
    word_id integer,
    current_level integer DEFAULT 1,
    max_level_reached integer DEFAULT 1,
    health_remaining integer DEFAULT 5,
    silk_earned integer DEFAULT 0,
    completed_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_quiz_progress OWNER TO postgres;

--
-- Name: user_quiz_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_quiz_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_quiz_progress_id_seq OWNER TO postgres;

--
-- Name: user_quiz_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_quiz_progress_id_seq OWNED BY public.user_quiz_progress.id;


--
-- Name: user_room_unlocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_room_unlocks (
    id integer NOT NULL,
    user_id integer,
    room_id integer,
    unlocked_at timestamp with time zone DEFAULT now(),
    silk_spent integer DEFAULT 0,
    silk_earned integer DEFAULT 0,
    completed_at timestamp with time zone
);


ALTER TABLE public.user_room_unlocks OWNER TO postgres;

--
-- Name: user_room_unlocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_room_unlocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_room_unlocks_id_seq OWNER TO postgres;

--
-- Name: user_room_unlocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_room_unlocks_id_seq OWNED BY public.user_room_unlocks.id;


--
-- Name: user_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_stats (
    id integer NOT NULL,
    user_id integer,
    silk_balance integer DEFAULT 0,
    words_mastered integer DEFAULT 0,
    quizzes_completed integer DEFAULT 0,
    total_health_lost integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_stats OWNER TO postgres;

--
-- Name: user_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_stats_id_seq OWNER TO postgres;

--
-- Name: user_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_stats_id_seq OWNED BY public.user_stats.id;


--
-- Name: user_story_study_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_story_study_attempts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    question_id integer NOT NULL,
    user_answer character varying(255) NOT NULL,
    is_correct boolean NOT NULL,
    attempted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_story_study_attempts OWNER TO postgres;

--
-- Name: user_story_study_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_story_study_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_story_study_attempts_id_seq OWNER TO postgres;

--
-- Name: user_story_study_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_story_study_attempts_id_seq OWNED BY public.user_story_study_attempts.id;


--
-- Name: user_story_study_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_story_study_progress (
    id integer NOT NULL,
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    story_completed boolean DEFAULT false,
    first_completion_at timestamp with time zone,
    last_studied_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    times_studied integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_story_study_progress OWNER TO postgres;

--
-- Name: user_story_study_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_story_study_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_story_study_progress_id_seq OWNER TO postgres;

--
-- Name: user_story_study_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_story_study_progress_id_seq OWNED BY public.user_story_study_progress.id;


--
-- Name: user_word_definitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_word_definitions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    initial_definition text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_word_definitions OWNER TO postgres;

--
-- Name: user_word_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_word_definitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_word_definitions_id_seq OWNER TO postgres;

--
-- Name: user_word_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_word_definitions_id_seq OWNED BY public.user_word_definitions.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


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
    story_intro text,
    learning_status character varying(20) DEFAULT 'unmastered'::character varying,
    CONSTRAINT vocab_entries_learning_status_check CHECK (((learning_status)::text = ANY ((ARRAY['unmastered'::character varying, 'learned'::character varying, 'mastered'::character varying])::text[])))
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
-- Name: beast_mode_attempts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_attempts ALTER COLUMN id SET DEFAULT nextval('public.beast_mode_attempts_id_seq'::regclass);


--
-- Name: beast_mode_cooldowns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_cooldowns ALTER COLUMN id SET DEFAULT nextval('public.beast_mode_cooldowns_id_seq'::regclass);


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
-- Name: floor_boss_scenarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floor_boss_scenarios ALTER COLUMN id SET DEFAULT nextval('public.floor_boss_scenarios_id_seq'::regclass);


--
-- Name: floors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors ALTER COLUMN id SET DEFAULT nextval('public.floors_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps ALTER COLUMN id SET DEFAULT nextval('public.maps_id_seq'::regclass);


--
-- Name: purchases id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases ALTER COLUMN id SET DEFAULT nextval('public.purchases_id_seq'::regclass);


--
-- Name: quiz_attempts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts ALTER COLUMN id SET DEFAULT nextval('public.quiz_attempts_id_seq'::regclass);


--
-- Name: quiz_materials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_materials ALTER COLUMN id SET DEFAULT nextval('public.quiz_materials_id_seq'::regclass);


--
-- Name: quiz_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_questions ALTER COLUMN id SET DEFAULT nextval('public.quiz_questions_id_seq'::regclass);


--
-- Name: quizzes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes ALTER COLUMN id SET DEFAULT nextval('public.quizzes_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: root_families id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.root_families ALTER COLUMN id SET DEFAULT nextval('public.root_families_id_seq'::regclass);


--
-- Name: semantic_domains id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semantic_domains ALTER COLUMN id SET DEFAULT nextval('public.semantic_domains_id_seq'::regclass);


--
-- Name: silk_transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.silk_transactions ALTER COLUMN id SET DEFAULT nextval('public.silk_transactions_id_seq'::regclass);


--
-- Name: story_comprehension_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_comprehension_questions ALTER COLUMN id SET DEFAULT nextval('public.story_comprehension_questions_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: user_floor_boss_attempts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_floor_boss_attempts ALTER COLUMN id SET DEFAULT nextval('public.user_floor_boss_attempts_id_seq'::regclass);


--
-- Name: user_map_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_map_progress ALTER COLUMN id SET DEFAULT nextval('public.user_map_progress_id_seq'::regclass);


--
-- Name: user_quiz_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_quiz_progress ALTER COLUMN id SET DEFAULT nextval('public.user_quiz_progress_id_seq'::regclass);


--
-- Name: user_room_unlocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_room_unlocks ALTER COLUMN id SET DEFAULT nextval('public.user_room_unlocks_id_seq'::regclass);


--
-- Name: user_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stats ALTER COLUMN id SET DEFAULT nextval('public.user_stats_id_seq'::regclass);


--
-- Name: user_story_study_attempts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_attempts ALTER COLUMN id SET DEFAULT nextval('public.user_story_study_attempts_id_seq'::regclass);


--
-- Name: user_story_study_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_progress ALTER COLUMN id SET DEFAULT nextval('public.user_story_study_progress_id_seq'::regclass);


--
-- Name: user_word_definitions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_word_definitions ALTER COLUMN id SET DEFAULT nextval('public.user_word_definitions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


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
-- Data for Name: beast_mode_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.beast_mode_attempts (id, user_id, word_id, wager_amount, success, silk_earned, attempted_at, completed_at, updated_at) FROM stdin;
1	5	1	85	f	0	2025-10-22 23:23:45.912095-04	\N	2025-10-23 02:48:16.212246-04
2	5	1	10	f	0	2025-10-22 23:54:42.216349-04	\N	2025-10-23 02:48:16.212246-04
3	5	1	10	f	0	2025-10-23 00:12:26.644808-04	\N	2025-10-23 02:48:16.212246-04
4	5	1	10	f	0	2025-10-23 00:13:11.659093-04	\N	2025-10-23 02:48:16.212246-04
5	5	1	1	f	0	2025-10-23 01:24:37.606553-04	\N	2025-10-23 02:48:16.212246-04
6	5	1	1	f	0	2025-10-23 01:26:11.496619-04	\N	2025-10-23 02:48:16.212246-04
7	5	1	1	f	0	2025-10-23 01:26:29.444502-04	\N	2025-10-23 02:48:16.212246-04
8	5	1	1	f	0	2025-10-23 01:27:32.576039-04	\N	2025-10-23 02:48:16.212246-04
9	5	1	1	f	0	2025-10-23 01:31:31.140567-04	\N	2025-10-23 02:48:16.212246-04
10	5	1	1	f	0	2025-10-23 01:32:42.628873-04	\N	2025-10-23 02:48:16.212246-04
11	5	56	1	f	0	2025-10-23 01:36:17.637897-04	\N	2025-10-23 02:48:16.212246-04
12	5	56	1	f	0	2025-10-23 01:42:11.576374-04	\N	2025-10-23 02:48:16.212246-04
13	5	56	1	f	0	2025-10-23 01:44:48.608154-04	\N	2025-10-23 02:48:16.212246-04
14	5	56	1	f	0	2025-10-23 01:45:29.315005-04	\N	2025-10-23 02:48:16.212246-04
15	5	56	1	f	0	2025-10-23 01:45:47.358228-04	\N	2025-10-23 02:48:16.212246-04
16	5	56	1	f	0	2025-10-23 01:47:19.990522-04	\N	2025-10-23 02:48:16.212246-04
17	5	56	1	f	0	2025-10-23 01:49:25.520951-04	\N	2025-10-23 02:48:16.212246-04
18	5	56	1	f	0	2025-10-23 01:51:53.022823-04	\N	2025-10-23 02:48:16.212246-04
19	5	56	1	f	0	2025-10-23 01:52:39.78141-04	\N	2025-10-23 02:48:16.212246-04
20	5	56	1	f	0	2025-10-23 01:53:47.535824-04	\N	2025-10-23 02:48:16.212246-04
21	5	56	1	f	0	2025-10-23 01:53:58.942155-04	\N	2025-10-23 02:48:16.212246-04
22	5	56	1	f	0	2025-10-23 01:58:22.040309-04	\N	2025-10-23 02:48:16.212246-04
23	5	56	1	f	0	2025-10-23 02:04:15.658471-04	\N	2025-10-23 02:48:16.212246-04
24	5	56	1	f	0	2025-10-23 02:12:20.241497-04	\N	2025-10-23 02:48:16.212246-04
25	5	56	1	f	0	2025-10-23 02:13:55.235673-04	\N	2025-10-23 02:48:16.212246-04
26	5	56	1	f	0	2025-10-23 02:16:15.089551-04	\N	2025-10-23 02:48:16.212246-04
27	5	56	33	f	0	2025-10-23 02:17:42.512345-04	\N	2025-10-23 02:48:16.212246-04
28	5	56	85	f	0	2025-10-23 02:20:51.930231-04	\N	2025-10-23 02:48:16.212246-04
29	5	56	90	f	0	2025-10-23 02:24:00.56743-04	\N	2025-10-23 02:48:16.212246-04
30	5	56	85	f	0	2025-10-23 02:24:52.3488-04	\N	2025-10-23 02:48:16.212246-04
31	5	56	90	f	0	2025-10-23 02:29:59.424081-04	\N	2025-10-23 02:48:16.212246-04
32	5	56	85	f	0	2025-10-23 02:45:41.333203-04	\N	2025-10-23 02:48:16.212246-04
33	5	56	85	f	0	2025-10-23 02:48:57.049301-04	2025-10-23 02:49:38.831121-04	2025-10-23 02:49:38.831121-04
34	5	1	85	f	0	2025-10-23 02:52:27.97593-04	2025-10-23 02:54:36.747073-04	2025-10-23 02:54:36.747073-04
35	5	1	85	f	0	2025-10-23 02:57:11.942407-04	\N	2025-10-23 02:57:11.942407-04
36	5	56	85	f	0	2025-10-23 02:57:54.465559-04	2025-10-23 02:58:30.632788-04	2025-10-23 02:58:30.632788-04
37	5	1	1	f	0	2025-10-24 00:38:48.040667-04	2025-10-24 00:40:05.351045-04	2025-10-24 00:40:05.351045-04
38	5	56	1	f	0	2025-10-24 00:40:35.019381-04	2025-10-24 00:41:18.015637-04	2025-10-24 00:41:18.015637-04
39	5	56	1	f	0	2025-10-24 01:05:57.028467-04	2025-10-24 01:06:47.226411-04	2025-10-24 01:06:47.226411-04
40	5	1	1	f	0	2025-10-24 01:07:33.494481-04	2025-10-24 01:10:17.45908-04	2025-10-24 01:10:17.45908-04
41	5	1	1	t	2	2025-10-24 01:12:50.861474-04	2025-10-24 01:13:47.46002-04	2025-10-24 01:13:47.46002-04
42	5	1	81	t	162	2025-10-24 01:14:26.790438-04	2025-10-24 01:15:02.60328-04	2025-10-24 01:15:02.60328-04
43	5	56	1	f	0	2025-10-24 16:13:37.882703-04	\N	2025-10-24 16:13:37.882703-04
44	5	56	1	f	0	2025-10-24 16:24:33.085375-04	\N	2025-10-24 16:24:33.085375-04
45	5	1	40	t	80	2025-10-24 19:57:10.127304-04	2025-10-24 19:58:11.274138-04	2025-10-24 19:58:11.274138-04
46	5	1	100	f	0	2025-10-25 18:23:47.635814-04	2025-10-25 18:25:08.887983-04	2025-10-25 18:25:08.887983-04
47	5	27	100	t	200	2025-10-27 15:44:08.172246-04	2025-10-27 15:46:02.180591-04	2025-10-27 15:46:02.180591-04
48	5	1	1	f	0	2025-10-27 17:10:28.607662-04	\N	2025-10-27 17:10:28.607662-04
\.


--
-- Data for Name: beast_mode_cooldowns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.beast_mode_cooldowns (id, user_id, word_id, last_attempt, cooldown_until) FROM stdin;
10	5	1	2025-10-25 18:25:08.892876-04	2025-10-25 19:25:08.892876-04
14	5	542	2025-10-27 10:27:56.389324-04	2025-10-27 11:27:56.389324-04
12	5	27	2025-10-27 15:46:02.215668-04	2025-10-27 16:46:02.215668-04
16	5	13	2025-10-27 19:31:12.133232-04	2025-10-27 20:31:12.133232-04
\.


--
-- Data for Name: causal_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.causal_tags (id, tag_name, description) FROM stdin;
6	fossilization	Older senses preserved only in idioms
7	bureaucratic_precision	\N
2	theological_moralization	Sense shaped by religious/moral frameworks
10	category_expansion	\N
11	religious_influence	\N
4	printing_revolution	Technological shift to print & editorial precision
14	editorial_professionalization	\N
3	bureaucratic_expansion	Administrative/legal textualization
16	category_refinement	\N
17	scientific_standardization	\N
8	legal_formalization	\N
24	semantic_abstraction	\N
424	commercial_extension	\N
369	intellectual_context	\N
192	prestige_loan	\N
193	aesthetic_formalization	\N
194	aesthetic_intensification	\N
34	scientific_context	\N
23	bureaucratization	\N
403	cultural_context	\N
64	technological_context	\N
47	semantic_stabilization	\N
374	ritualization	\N
57	bureaucratic_origin	\N
379	psychological_context	\N
1	lexical_competition	Shift due to competition within a root family
66	moral_connotation	\N
380	borrowing_contact	\N
372	metonymy	\N
70	editorialization	\N
32	political_context	\N
385	literary_context	\N
388	onomatopoeia	\N
375	semantic_narrowing	\N
40	sociological_context	\N
376	metaphorization	\N
43	technological_origin	\N
44	compound_formation	\N
26	industrial_context	\N
42	organizational_context	\N
48	colloquial_extension	\N
51	technological_extension	\N
21	moralization	\N
22	metaphoric_extension	\N
401	emotional_context	\N
19	physical_metaphor	\N
111	duty_ethic	\N
113	spiritual_shift	\N
406	verbal_formation	\N
115	humanist_reinterpretation	\N
12	language_transition	\N
408	intellectual_extension	\N
409	ideological_context	\N
18	semantic_neutralization	\N
121	intentional_absence	\N
411	institutional_context	\N
123	religious_context	\N
412	theatrical_origin	\N
20	lexical_origin	\N
125	legal_precision	\N
126	technological_shift	\N
29	philosophical_extension	\N
416	social_extension	\N
129	discursive_divergence	\N
364	legal_term	\N
31	semantic_extension	\N
5	discursive_specialization	Stabilization in scientific/legal prose
420	theological_origin	\N
421	lexical_formation	\N
37	scientific_extension	\N
\.


--
-- Data for Name: citations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citations (id, event_id, source, url, quote, added_at) FROM stdin;
\.


--
-- Data for Name: derivations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.derivations (id, parent_vocab_id, child_vocab_id, relation_type, notes) FROM stdin;
1	11	1	derives_from	Verb form, from which 'omission' is derived
2	1	15	affixation	Adjective formed by adding -ible suffix
\.


--
-- Data for Name: floor_boss_scenarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floor_boss_scenarios (id, floor_id, scenario_text, correct_word_id, difficulty_level, created_at) FROM stdin;
45	25	A situation or context where the word "verisimilitude" would be the most appropriate and precise choice to describe what is happening.	187	1	2025-10-24 16:57:43.459165-04
46	25	An academic or professional setting where understanding "verisimilitude" is essential for success or comprehension.	187	1	2025-10-24 16:57:43.45983-04
\.


--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floors (id, map_id, floor_number, name, description, unlock_requirement, boss_challenge_type, silk_reward, created_at) FROM stdin;
25	3	1	The Foundation	The first floor where all eight master words await your challenge. Each room contains a complete vocabulary experience with all quiz levels and Beast Mode.	Complete the tutorial and earn your first 50 Silk	scenario_typing	200	2025-10-24 16:57:43.446745-04
26	3	2	The Archives	The second floor holds deeper mysteries. Eight new words await mastery, each unlocking greater understanding of the world's hidden nature.	Complete Floor 1 Guardian Challenge	scenario_typing	200	2025-10-28 03:50:57.129079-04
\.


--
-- Data for Name: maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maps (id, name, description, total_floors, created_at) FROM stdin;
3	The Tower of Words	A mystical tower where each floor contains rooms filled with ancient vocabulary treasures. Only the most complete and challenging words await your mastery.	1	2025-10-24 16:57:43.44506-04
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchases (id, user_id, token_id, purchased_at) FROM stdin;
\.


--
-- Data for Name: quiz_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_attempts (id, quiz_id, level, is_correct, attempted_at) FROM stdin;
1	70	1	t	2025-10-21 03:48:57.299541
2	70	2	t	2025-10-21 03:49:49.617987
3	70	3	f	2025-10-21 03:50:04.230261
4	70	3	f	2025-10-21 03:50:17.924316
5	70	3	f	2025-10-21 03:50:33.570243
6	70	3	f	2025-10-21 03:50:48.516087
7	70	3	t	2025-10-21 03:53:54.14599
9	187	1	t	2025-10-22 17:33:32.507968
8	187	1	t	2025-10-22 17:33:32.507833
10	187	2	t	2025-10-22 17:33:38.96045
11	187	3	t	2025-10-22 17:33:59.711873
12	187	4	t	2025-10-22 17:34:28.005943
14	70	4	t	2025-10-22 17:35:23.285647
19	70	1	t	2025-10-22 20:02:27.858572
20	70	1	t	2025-10-22 20:02:27.858668
21	70	2	t	2025-10-22 20:02:32.015433
22	70	3	t	2025-10-22 20:02:40.104352
23	70	4	t	2025-10-22 20:02:58.375422
26	83	1	t	2025-10-22 20:05:06.585019
27	83	1	t	2025-10-22 20:05:06.585256
28	83	2	t	2025-10-22 20:05:09.854818
29	83	3	t	2025-10-22 20:05:20.357434
30	83	4	t	2025-10-22 20:05:34.015495
33	56	1	t	2025-10-22 20:21:16.420253
34	56	1	t	2025-10-22 20:21:16.420463
35	56	2	f	2025-10-22 20:21:18.511786
36	56	2	t	2025-10-22 20:21:25.523136
37	56	3	t	2025-10-22 20:21:35.092851
38	56	4	t	2025-10-22 20:21:49.237383
48	56	5	t	2025-10-22 23:09:45.662916
49	27	1	t	2025-10-25 12:01:43.922919
50	27	1	t	2025-10-25 12:01:43.923566
51	27	2	t	2025-10-25 12:01:49.463347
52	27	3	t	2025-10-25 12:01:57.291544
53	27	4	t	2025-10-25 12:02:10.095331
54	27	5	f	2025-10-25 12:03:26.476059
56	42	1	t	2025-10-25 12:52:32.100506
55	42	1	t	2025-10-25 12:52:32.100424
57	42	2	t	2025-10-25 12:52:37.859838
58	42	3	t	2025-10-25 12:52:58.291279
59	42	4	t	2025-10-25 12:53:35.187885
60	27	5	t	2025-10-25 17:36:24.53958
62	496	1	t	2025-10-27 02:59:18.631685
61	496	1	t	2025-10-27 02:59:18.631417
63	496	2	t	2025-10-27 02:59:22.772944
64	542	1	t	2025-10-27 10:12:57.171097
65	542	1	t	2025-10-27 10:12:57.171507
66	542	2	t	2025-10-27 10:13:02.508517
67	542	3	t	2025-10-27 10:13:08.876064
68	542	4	t	2025-10-27 10:19:02.609956
69	542	5	f	2025-10-27 10:24:00.220148
70	542	5	f	2025-10-27 10:24:39.057167
71	542	5	f	2025-10-27 10:27:30.450144
72	542	5	t	2025-10-27 10:27:56.36597
73	13	1	t	2025-10-27 19:26:19.231638
74	13	1	t	2025-10-27 19:26:19.231244
75	13	2	t	2025-10-27 19:26:30.212094
76	13	3	f	2025-10-27 19:26:53.253417
77	13	3	t	2025-10-27 19:28:21.004695
78	13	4	t	2025-10-27 19:29:20.453438
79	13	5	t	2025-10-27 19:31:12.108568
80	542	1	t	2025-10-28 04:20:30.804303
81	542	1	t	2025-10-28 04:20:30.804365
82	542	2	t	2025-10-28 04:20:36.113121
\.


--
-- Data for Name: quiz_materials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_materials (id, word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount, created_at, updated_at) FROM stdin;
251	27	1	spelling	Spell the word 'cohesive'	\N	"cohesive"	\N	5	2025-10-27 18:46:12.839327	2025-10-27 18:46:12.839327
252	27	2	typing	Type the word 'cohesive'	\N	"cohesive"	\N	8	2025-10-27 18:46:12.868011	2025-10-27 18:46:12.868011
253	27	3	definition	What does 'cohesive' mean?	{"correct_answers": ["forming a united whole; characterized by or causing cohesion."], "incorrect_answers": ["fragmented", "disjointed", "dispersed"]}	"forming a united whole; characterized by or causing cohesion."	\N	12	2025-10-27 18:46:12.869759	2025-10-27 18:46:12.869759
254	27	4	synonym	Select the synonyms of 'cohesive'	{"antonyms": ["fragmented", "disjointed", "dispersed", "incoherent", "scattered", "disconnected"], "synonyms": ["unified", "connected", "integrated", "consistent", "harmonious"], "red_herrings": ["fragmented", "disjointed", "dispersed", "incoherent"]}	["unified","connected","integrated","consistent","harmonious"]	\N	15	2025-10-27 18:46:12.871632	2025-10-27 18:46:12.871632
255	27	5	story	Match each time period with its stage in the story of 'cohesive', then arrange them in order:	{"turns": ["In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.", "When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.", "The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.", "Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."], "settings": ["Rome", "Scientific Revolution", "Industrial Age", "Modern Management"], "time_periods": ["1st c. CE", "17th c.", "19th c.", "20th c."]}	["1st c. CE — Rome → In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.","17th c. — Scientific Revolution → When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.","19th c. — Industrial Age → The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.","20th c. — Modern Management → Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how the force of binding moved from matter to mind.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.873593	2025-10-27 18:46:12.873593
53	13	1	spelling	Unscramble the letters to form the word that means 'existing as a natural or essential part of something':	["ehrinhe", "reniheh", "inherent", "herinent"]	inherent	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
256	27	6	story	Rebuild the full story of 'cohesive'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.", "When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.", "The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.", "Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary.", "He was adopted by Carolingian architects to describe the unity of stone and mortar.", "He became the motto of medieval guilds celebrating craft unity.", "He symbolized the romantic ideal of organic social harmony."], "settings": ["Rome", "Scientific Revolution", "Industrial Age", "Modern Management", "Carolingian Empire", "Medieval Guilds", "Romantic Movement"], "red_herrings": ["He was adopted by Carolingian architects to describe the unity of stone and mortar— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissanc", "He became the motto of medieval guilds celebrating craft unity— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumption", "He symbolized the romantic ideal of organic social harmony— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumptions, pushing her "], "time_periods": ["1st c. CE", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.","17th c. — Scientific Revolution → When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.","19th c. — Industrial Age → The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.","20th c. — Modern Management → Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.878604	2025-10-27 18:46:12.878604
257	1	1	spelling	Spell the word 'impede'	\N	"impede"	\N	5	2025-10-27 18:46:12.883753	2025-10-27 18:46:12.883753
258	1	2	typing	Type the word 'impede'	\N	"impede"	\N	8	2025-10-27 18:46:12.884938	2025-10-27 18:46:12.884938
54	13	2	typing	Type the vocabulary word defined as 'existing as a natural or essential part of something.'	{}	inherent	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
141	457	1	spelling	Arrange the letters to spell the word:	\N	pall	\N	10	2025-10-27 02:56:18.957055	2025-10-27 03:06:12.178106
142	457	2	typing	Type the word you just arranged:	\N	(?i)^pall$	\N	10	2025-10-27 02:56:18.958341	2025-10-27 03:06:12.17953
143	457	3	definition	Select all definitions that accurately describe 'pall':	{"correct_answers": ["A heavy, dark cloth covering, especially for mourning", "A gloomy or depressing atmosphere", "To become dull or less interesting", "Something that spreads sadness or gloom"], "incorrect_answers": ["A bright and cheerful atmosphere", "Something that brings joy and excitement", "A feeling of lightness and freedom", "An uplifting or inspiring quality", "A celebration or festivity", "Something that energizes and motivates", "A sense of hope and optimism", "An atmosphere of happiness"]}	\N	{"feedback": {"fail": "Some shone too brightly.", "hint": "Think of what covers and darkens.", "success": "You felt the weight of gloom."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.960102	2025-10-27 03:06:12.180841
55	13	3	definition	Select the best definition of 'inherent'.	["Existing as a natural or essential part of something.", "Developed through learning or habit.", "Accidental or temporary in nature.", "Dependent on outside influence."]	Existing as a natural or essential part of something.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
56	70	1	spelling	Unscramble the letters to form the word that means 'done with minimal effort or care':	["fruorynctp", "perfunctory", "punctferory", "perfunctyro"]	perfunctory	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
57	70	2	typing	Type the vocabulary word defined as 'done with minimal effort or care.'	{}	perfunctory	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
58	70	3	definition	Select the best definition of 'perfunctory'.	["Done with minimal effort or reflection.", "Marked by deep attention and sincerity.", "Performed with excitement and curiosity.", "Built upon careful preparation."]	Done with minimal effort or reflection.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
59	42	1	spelling	Unscramble the letters to form the word that means 'lacking focus or organization; spread over a wide area':	["sttshaocret", "scattershot", "stsochatter", "sctthsoater"]	scattershot	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
259	1	3	definition	What does 'impede' mean?	{"correct_answers": ["to slow or block progress, movement, or development."], "incorrect_answers": ["assist", "facilitate", "enable"]}	"to slow or block progress, movement, or development."	\N	12	2025-10-27 18:46:12.886019	2025-10-27 18:46:12.886019
260	1	4	synonym	Select the synonyms of 'impede'	{"antonyms": ["assist", "facilitate", "enable", "promote", "advance"], "synonyms": ["obstruction", "delay", "resistance", "inhibition"], "red_herrings": ["assist", "facilitate", "enable", "promote"]}	["obstruction","delay","resistance","inhibition"]	\N	15	2025-10-27 18:46:12.887119	2025-10-27 18:46:12.887119
261	1	5	story	Match each time period with its stage in the story of 'impede', then arrange them in order:	{"turns": ["Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.", "When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.", "Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.", "By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."], "settings": ["Rome", "Medieval Christianity", "Renaissance Humanism", "Industrial Age"], "time_periods": ["1st c. CE", "14th c.", "16th c.", "19th c."]}	["1st c. CE — Rome → Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.","14th c. — Medieval Christianity → When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.","16th c. — Renaissance Humanism → Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.","19th c. — Industrial Age → By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how obstruction moved from body to system.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.888093	2025-10-27 18:46:12.888093
144	457	4	syn_ant_sort	Drag each word into the correct basket for 'pall':	{"antonyms": ["brightness", "cheer", "joy", "lightness"], "synonyms": ["shroud", "gloom", "melancholy", "cloud"], "red_herrings": ["cloth", "covering", "veil", "cover"]}	\N	{"feedback": {"fail": "Some landed in the wrong light.", "hint": "Listen for dark vs. light.", "success": "You separated the shadows from the sun."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.961247	2025-10-27 03:06:12.182116
102	457	4	syn_ant_sort	Drag each word into the correct basket for 'pall':	{"antonyms": ["brightness", "cheer", "joy", "lightness"], "synonyms": ["shroud", "gloom", "melancholy", "cloud"], "red_herrings": ["cloth", "covering", "veil", "cover"]}	\N	{"feedback": {"fail": "Some landed in the wrong light.", "hint": "Listen for dark vs. light.", "success": "You separated the shadows from the sun."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.566872	2025-10-27 03:06:12.182116
94	443	1	spelling	Arrange the letters to spell the word:	\N	attest	\N	10	2025-10-26 01:16:50.548339	2025-10-27 03:06:12.166754
97	443	4	syn_ant_sort	Drag each word into the correct basket for 'attest':	{"antonyms": ["deny", "refute", "dispute", "contradict"], "synonyms": ["testify", "verify", "confirm", "certify"], "red_herrings": ["witness", "statement", "claim", "affirm"]}	\N	{"feedback": {"fail": "Some landed in the wrong court.", "hint": "Listen for truth vs. falsehood.", "success": "You separated the witnesses from the deniers."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.557423	2025-10-27 03:06:12.173359
99	457	1	spelling	Arrange the letters to spell the word:	\N	pall	\N	10	2025-10-26 01:16:50.56319	2025-10-27 03:06:12.178106
100	457	2	typing	Type the word you just arranged:	\N	(?i)^pall$	\N	10	2025-10-26 01:16:50.564471	2025-10-27 03:06:12.17953
101	457	3	definition	Select all definitions that accurately describe 'pall':	{"correct_answers": ["A heavy, dark cloth covering, especially for mourning", "A gloomy or depressing atmosphere", "To become dull or less interesting", "Something that spreads sadness or gloom"], "incorrect_answers": ["A bright and cheerful atmosphere", "Something that brings joy and excitement", "A feeling of lightness and freedom", "An uplifting or inspiring quality", "A celebration or festivity", "Something that energizes and motivates", "A sense of hope and optimism", "An atmosphere of happiness"]}	\N	{"feedback": {"fail": "Some shone too brightly.", "hint": "Think of what covers and darkens.", "success": "You felt the weight of gloom."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.565681	2025-10-27 03:06:12.180841
145	457	5	story_reorder	Match each time period with its stage in the story of 'pall', then arrange them in order:	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature"], "red_herrings": ["He was always a verb of excitement.", "He disappeared completely in the 16th century."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how cloth became weariness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 02:56:18.962386	2025-10-27 03:06:12.183388
146	469	1	spelling	Arrange the letters to spell the word:	\N	lumbering	\N	10	2025-10-27 02:56:18.963407	2025-10-27 03:06:12.184784
147	469	2	typing	Type the word you just arranged:	\N	(?i)^lumbering$	\N	10	2025-10-27 02:56:18.964395	2025-10-27 03:06:12.185774
148	469	3	definition	Select all definitions that accurately describe 'lumbering':	{"correct_answers": ["Moving in a slow, heavy, awkward way", "Characterized by ponderous or clumsy movement", "Making a heavy, thudding sound when moving", "Ungainly or unwieldy in motion"], "incorrect_answers": ["Moving with grace and elegance", "Light and nimble in motion", "Quick and agile movement", "Smooth and fluid gestures", "Delicate and refined motion", "Swift and effortless action", "Flexible and supple movement", "Graceful and coordinated steps"]}	\N	{"feedback": {"fail": "Some moved too lightly.", "hint": "Think of weight made movement.", "success": "You felt the earth shake."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.965345	2025-10-27 03:06:12.186774
262	1	6	story	Rebuild the full story of 'impede'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.", "When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.", "Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.", "By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine.", "He was adopted by Charlemagne's scribes to describe the weight of imperial decrees.", "He became a battle cry for knights charging into holy war.", "He symbolized the rational perfection of bureaucratic order."], "settings": ["Rome", "Medieval Christianity", "Renaissance Humanism", "Industrial Age", "Carolingian Empire", "Crusades", "Enlightenment"], "red_herrings": ["He was adopted by Charlemagne's scribes to describe the weight of imperial decrees— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assu", "He followed the Crusaders as the enemy of divine progress— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumptions, pushing her boundaries. Enlightenm", "He was reimagined by Enlightenment thinkers as the natural r Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumptions, pushing her boundaries. E"], "time_periods": ["1st c. CE", "14th c.", "16th c.", "19th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.","14th c. — Medieval Christianity → When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.","16th c. — Renaissance Humanism → Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.","19th c. — Industrial Age → By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.889778	2025-10-27 18:46:12.889778
263	13	1	spelling	Spell the word 'inherent'	\N	"inherent"	\N	5	2025-10-27 18:46:12.890871	2025-10-27 18:46:12.890871
264	13	2	typing	Type the word 'inherent'	\N	"inherent"	\N	8	2025-10-27 18:46:12.892289	2025-10-27 18:46:12.892289
265	13	3	definition	What does 'inherent' mean?	{"correct_answers": ["existing as a permanent, essential, or characteristic attribute of something."], "incorrect_answers": ["external", "acquired", "extrinsic"]}	"existing as a permanent, essential, or characteristic attribute of something."	\N	12	2025-10-27 18:46:12.893636	2025-10-27 18:46:12.893636
266	13	4	synonym	Select the synonyms of 'inherent'	{"antonyms": ["external", "acquired", "extrinsic", "adventitious"], "synonyms": ["intrinsic", "innate", "essential", "built-in", "fundamental", "native"], "red_herrings": ["external", "acquired", "extrinsic", "adventitious"]}	["intrinsic","innate","essential","built-in","fundamental","native"]	\N	15	2025-10-27 18:46:12.894467	2025-10-27 18:46:12.894467
267	13	5	story	Match each time period with its stage in the story of 'inherent', then arrange them in order:	{"turns": ["In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.", "In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.", "When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.", "Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."], "settings": ["Rome", "Medieval Philosophy", "Enlightenment", "Modern Science"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "20th c."]}	["1st c. CE — Rome → In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.","14th c. — Medieval Philosophy → In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.","17th c. — Enlightenment → When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.","20th c. — Modern Science → Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how the idea of what belongs within moved from matter to morality.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.89538	2025-10-27 18:46:12.89538
44	187	1	spelling	Arrange the letters to spell the word:	\N	verisimilitude	\N	10	2025-10-21 14:12:40.325956	2025-10-21 14:12:40.325956
45	187	2	typing	Type the word you just arranged:	\N	verisimilitude	{"case_insensitive": true}	10	2025-10-21 14:12:40.329279	2025-10-21 14:12:40.329279
46	187	3	definition	Select all definitions that accurately describe 'verisimilitude':	{"correct_answers": ["The appearance or quality of being true or real", "The quality of seeming to be true or plausible", "Believability or lifelike quality in fiction or art", "The semblance of truth based on probability"], "incorrect_answers": ["Absolute and verifiable truth", "The act of deliberately deceiving others", "Complete accuracy in all factual details", "Objective reality independent of perception", "Scientific proof or empirical evidence", "Honesty and moral integrity", "Exact replication without interpretation", "Divine or absolute certainty"]}	\N	{"feedback": {"fail": "Some held too much certainty; she deals in likeness, not proof.", "hint": "Think of seeming true, not being true.", "success": "You caught the shadow of truth without mistaking it for the light."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-21 14:12:40.330442	2025-10-21 14:12:40.330442
47	187	4	synonym	Drag each word into the correct basket for 'verisimilitude':	{"antonyms": ["implausibility", "incredibility", "unreality", "falseness"], "synonyms": ["plausibility", "believability", "realism", "credibility"], "red_herrings": ["accuracy", "honesty", "certainty", "verification"]}	\N	{"feedback": {"fail": "Some words claimed too much—or too little—truth.", "hint": "She resembles truth but isn't its twin.", "success": "You sorted appearance from substance with precision."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-21 14:12:40.331667	2025-10-21 14:12:40.331667
50	1	1	spelling	Unscramble the letters to form the word that means 'to block progress':	["impdee", "imepde", "epdmei", "impede"]	impede	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
51	1	2	typing	Type the vocabulary word defined as 'to slow or block progress, movement, or development.'	{}	impede	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
52	1	3	definition	Select the best definition of 'impede'.	["To slow or block progress, movement, or development.", "To encourage or make faster.", "To measure the speed of something.", "To prepare something in advance."]	To slow or block progress, movement, or development.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
268	13	6	story	Rebuild the full story of 'inherent'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.", "In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.", "When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.", "Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together.", "He was adopted by Carolingian monks to describe the divine spark in all creation.", "He became the cornerstone of scholastic debates about essence and accident.", "He symbolized the romantic notion of natural genius and inspiration."], "settings": ["Rome", "Medieval Philosophy", "Enlightenment", "Modern Science", "Carolingian Renaissance", "Scholasticism", "Romantic Era"], "red_herrings": ["He was adopted by Carolingian monks to describe the divine spark in all creation— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questi", "He became the cornerstone of scholastic debates about essence and accident— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumptions, pushing her boundar", "He symbolized the romantic notion of natural genius and inspiration— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers questioned her assumptions,"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.","14th c. — Medieval Philosophy → In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.","17th c. — Enlightenment → When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.","20th c. — Modern Science → Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.896455	2025-10-27 18:46:12.896455
269	83	1	spelling	Spell the word 'omit'	\N	"omit"	\N	5	2025-10-27 18:46:12.898064	2025-10-27 18:46:12.898064
270	83	2	typing	Type the word 'omit'	\N	"omit"	\N	8	2025-10-27 18:46:12.899055	2025-10-27 18:46:12.899055
271	83	3	definition	What does 'omit' mean?	{"correct_answers": ["to leave out or exclude intentionally or accidentally."], "incorrect_answers": ["include", "retain", "insert"]}	"to leave out or exclude intentionally or accidentally."	\N	12	2025-10-27 18:46:12.899851	2025-10-27 18:46:12.899851
272	83	4	synonym	Select the synonyms of 'omit'	{"antonyms": ["include", "retain", "insert", "add"], "synonyms": ["exclude", "leave out", "skip", "neglect", "ignore"], "red_herrings": ["include", "retain", "insert", "add"]}	["exclude","leave out","skip","neglect","ignore"]	\N	15	2025-10-27 18:46:12.900608	2025-10-27 18:46:12.900608
70	1	4	synonym	Drag each word into the correct column: synonyms vs. antonyms of 'impede'.	{"antonyms": ["assist", "facilitate", "enable", "advance"], "synonyms": ["obstruct", "delay", "inhibit", "hinder"]}	obstruct, delay, inhibit, hinder	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
72	13	4	synonym	Sort the following words into synonyms and antonyms of 'inherent'.	{"antonyms": ["extrinsic", "acquired", "external", "incidental"], "synonyms": ["intrinsic", "innate", "essential", "fundamental"]}	intrinsic, innate, essential, fundamental	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
74	70	4	synonym	Sort the following words into synonyms and antonyms of 'perfunctory'.	{"antonyms": ["thorough", "diligent", "intentional", "sincere"], "synonyms": ["automatic", "mechanical", "superficial", "unthinking"]}	automatic, mechanical, superficial, unthinking	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
60	42	2	typing	Type the vocabulary word defined as 'lacking focus or organization; spread over a wide area.'	{}	scattershot	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
61	42	3	definition	Select the best definition of 'scattershot'.	["Lacking focus or organization; spread over a wide area.", "Precise and carefully targeted.", "Repetitive and predictable in pattern.", "Done secretly or with hesitation."]	Lacking focus or organization; spread over a wide area.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
76	42	4	synonym	Sort the following words into synonyms and antonyms of 'scattershot'.	{"antonyms": ["systematic", "targeted", "methodical", "deliberate"], "synonyms": ["random", "indiscriminate", "unfocused", "erratic"]}	random, indiscriminate, unfocused, erratic	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
62	83	1	spelling	Unscramble the letters to form the word that means 'to leave out or exclude':	["tiom", "moit", "omit", "itmo"]	omit	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
63	83	2	typing	Type the vocabulary word defined as 'to leave out or exclude'.	{}	omit	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
64	83	3	definition	Select the best definition of 'omit'.	["To leave out or exclude.", "To include something additional.", "To repeat something unnecessarily.", "To summarize something briefly."]	To leave out or exclude.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
79	83	4	synonym	Sort the following words into synonyms and antonyms of 'omit'.	{"antonyms": ["include", "insert", "add", "mention"], "synonyms": ["exclude", "neglect", "skip", "leave out"]}	exclude, neglect, skip, leave out	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
65	27	1	spelling	Unscramble the letters to form the word that means 'sticking together; forming a united whole':	["chsieeov", "cohesive", "siecohev", "ceishove"]	cohesive	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
66	27	2	typing	Type the vocabulary word defined as 'sticking together; forming a united whole.'	{}	cohesive	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
67	27	3	definition	Select the best definition of 'cohesive'.	["Sticking together; forming a united whole.", "Falling apart easily; lacking unity.", "Existing as a separate or detached entity.", "Difficult to understand or explain."]	Sticking together; forming a united whole.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
68	56	1	spelling	Unscramble the letters to form the word that means 'most noticeable or important':	["salniet", "lantesi", "salient", "sailent"]	salient	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
69	56	2	typing	Type the vocabulary word defined as 'most noticeable or important.'	{}	salient	{"difficulty": "easy"}	10	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
78	56	3	definition	Select the best definition of 'salient'.	["Most noticeable or important.", "Hidden or obscure.", "Gradual or subtle in appearance.", "Minor or secondary in nature."]	Most noticeable or important.	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
184	28	4	syn_ant_sort	Drag each word into the correct basket for 'attest':	{"antonyms": ["deny", "refute", "dispute", "contradict"], "synonyms": ["testify", "verify", "confirm", "certify"], "red_herrings": ["witness", "statement", "claim", "affirm"]}	\N	{"feedback": {"fail": "Some landed in the wrong court.", "hint": "Listen for truth vs. falsehood.", "success": "You separated the witnesses from the deniers."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.412988	2025-10-27 14:09:51.536467
273	83	5	story	Match each time period with its stage in the story of 'omit', then arrange them in order:	{"turns": ["In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.", "In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.", "When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.", "With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.", "Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."], "settings": ["Rome", "Medieval Theology", "Late Medieval Bureaucracy", "Renaissance Printing", "Modern English"], "time_periods": ["1st c. CE", "12th c.", "15th c.", "16th c.", "20th c."]}	["1st c. CE — Rome → In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.","12th c. — Medieval Theology → In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.","15th c. — Late Medieval Bureaucracy → When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.","16th c. — Renaissance Printing → With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.","20th c. — Modern English → Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how absence becomes its own kind of presence.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.902045	2025-10-27 18:46:12.902045
274	83	6	story	Rebuild the full story of 'omit'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.", "In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.", "When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.", "With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.", "Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame.", "He was adopted by Carolingian scribes to describe the art of diplomatic silence—where the strategic omission that preserved peace between kingdoms became a skill of statecraft.", "He symbolized the Enlightenment ideal of rational restraint and precision—where deliberate exclusion of unnecessary elements became the methodological principle of clear thought."], "settings": ["Rome", "Medieval Theology", "Late Medieval Bureaucracy", "Renaissance Printing", "Modern English", "Carolingian Empire", "Enlightenment"], "red_herrings": ["He was adopted by Carolingian scribes to describe the art of diplomatic silence—where the strategic omission that preserved peace between kingdoms became a skill of statecraft. Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval schol", "He symbolized the Enlightenment ideal of rational restraint and precision—where deliberate exclusion of unnecessary elements became the methodological principle of clear thought. "], "time_periods": ["1st c. CE", "12th c.", "15th c.", "16th c.", "20th c.", "8th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.","12th c. — Medieval Theology → In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.","15th c. — Late Medieval Bureaucracy → When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.","16th c. — Renaissance Printing → With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.","20th c. — Modern English → Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.902927	2025-10-27 18:46:12.902927
275	70	1	spelling	Spell the word 'perfunctory'	\N	"perfunctory"	\N	5	2025-10-27 18:46:12.903778	2025-10-27 18:46:12.903778
182	28	2	typing	Type the word you just arranged:	\N	(?i)^attest$	\N	10	2025-10-27 03:06:33.409007	2025-10-27 14:09:51.532381
276	70	2	typing	Type the word 'perfunctory'	\N	"perfunctory"	\N	8	2025-10-27 18:46:12.904414	2025-10-27 18:46:12.904414
277	70	3	definition	What does 'perfunctory' mean?	{"correct_answers": ["done quickly and without real interest, care, or effort."], "incorrect_answers": ["thorough", "careful", "deliberate"]}	"done quickly and without real interest, care, or effort."	\N	12	2025-10-27 18:46:12.905124	2025-10-27 18:46:12.905124
278	70	4	synonym	Select the synonyms of 'perfunctory'	{"antonyms": ["thorough", "careful", "deliberate", "attentive", "conscientious"], "synonyms": ["cursory", "mechanical", "superficial", "indifferent", "unthinking"], "red_herrings": ["thorough", "careful", "deliberate", "attentive"]}	["cursory","mechanical","superficial","indifferent","unthinking"]	\N	15	2025-10-27 18:46:12.905916	2025-10-27 18:46:12.905916
81	27	4	synonym	Sort the following words into synonyms and antonyms of 'cohesive'.	{"antonyms": ["fragmented", "disjointed", "separate", "divided"], "synonyms": ["united", "bonded", "connected", "integrated"]}	united, bonded, connected, integrated	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
83	56	4	synonym	Sort the following words into synonyms and antonyms of 'salient'.	{"antonyms": ["inconspicuous", "minor", "obscure", "unremarkable"], "synonyms": ["prominent", "striking", "notable", "conspicuous"]}	prominent, striking, notable, conspicuous	{"difficulty": "medium"}	15	2025-10-22 20:04:12.429142	2025-10-22 20:04:12.429142
151	483	1	spelling	Arrange the letters to spell the word:	\N	scurry	\N	10	2025-10-27 02:56:18.968303	2025-10-27 03:06:12.190986
152	483	2	typing	Type the word you just arranged:	\N	(?i)^scurry$	\N	10	2025-10-27 02:56:18.969035	2025-10-27 03:06:12.191926
183	28	3	definition	Select all definitions that accurately describe 'attest':	{"correct_answers": ["To provide clear evidence or proof of something", "To bear witness or testify to a fact", "To certify or verify as true", "To declare or affirm formally"], "incorrect_answers": ["To deny or refute something", "To hide or conceal evidence", "To remain silent about facts", "To avoid providing proof", "To contradict a statement", "To dismiss as false", "To refuse to acknowledge", "To suppress information"]}	\N	{"feedback": {"fail": "Some hid what should be seen.", "hint": "Think of standing with truth.", "success": "You witnessed what matters."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.410975	2025-10-27 14:09:51.534453
279	70	5	story	Match each time period with its stage in the story of 'perfunctory', then arrange them in order:	{"turns": ["In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.", "When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.", "In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.", "Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.", "Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Life"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c."]}	["1st c. CE — Rome → In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.","12th c. — Medieval Church → When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.","16th c. — Renaissance Humanism → In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.","19th c. — Industrial Age → Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.","21st c. — Digital Life → Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how repetition without meaning turns duty into emptiness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.906672	2025-10-27 18:46:12.906672
280	70	6	story	Rebuild the full story of 'perfunctory'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.", "When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.", "In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.", "Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.", "Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing.", "He was adopted by Carolingian monks to perfect the divine liturgy through mechanical precision—where ritual completion was valued above heartfelt devotion. In their scriptoria, he represented the duty of the faithful to perform pray", "He became the code of Crusader knights who performed their sacred duties without emotion or passion—where steadfast action was prized over inner conviction. In their chronicles, he embodied the warrior's ethic of executing orders exactly as ", "He symbolized the Romantic rejection of all mechanical work in favor of spontaneous creative inspiration—where natural feeling triumphed over disciplined routine. Romantic poets used him to describe the enemy of"], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Age", "Carolingian Empire", "Crusader States", "Romantic Movement"], "red_herrings": ["He was adopted by Carolingian monks to perfect the divine liturgy through mechanical precision—where ritual completion was valued above heartfelt devotion. In their scriptoria, he represented the duty of the faithful to perform pray", "He became the code of Crusader knights who performed their sacred duties without emotion or passion—where steadfast action was prized over inner conviction. In their chronicles, he embodied the warrior's ethic of executing orders exactly as ", "He symbolized the Romantic rejection of all mechanical work in favor of spontaneous creative inspiration—where natural feeling triumphed over disciplined routine. Romantic poets used him to describe the enemy of"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c.", "8th c.", "14th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.","12th c. — Medieval Church → When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.","16th c. — Renaissance Humanism → In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.","19th c. — Industrial Age → Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.","21st c. — Digital Life → Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.908067	2025-10-27 18:46:12.908067
281	56	1	spelling	Spell the word 'salient'	\N	"salient"	\N	5	2025-10-27 18:46:12.908895	2025-10-27 18:46:12.908895
282	56	2	typing	Type the word 'salient'	\N	"salient"	\N	8	2025-10-27 18:46:12.910507	2025-10-27 18:46:12.910507
283	56	3	definition	What does 'salient' mean?	{"correct_answers": ["most noticeable or important; prominent or striking."], "incorrect_answers": ["obscure", "inconspicuous", "hidden"]}	"most noticeable or important; prominent or striking."	\N	12	2025-10-27 18:46:12.911188	2025-10-27 18:46:12.911188
284	56	4	synonym	Select the synonyms of 'salient'	{"antonyms": ["obscure", "inconspicuous", "hidden", "minor"], "synonyms": ["prominent", "notable", "striking", "conspicuous", "remarkable", "outstanding"], "red_herrings": ["obscure", "inconspicuous", "hidden", "minor"]}	["prominent","notable","striking","conspicuous","remarkable","outstanding"]	\N	15	2025-10-27 18:46:12.911919	2025-10-27 18:46:12.911919
285	56	5	story	Match each time period with its stage in the story of 'salient', then arrange them in order:	{"turns": ["In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.", "In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.", "Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.", "By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.", "By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring."], "settings": ["Rome", "Medieval France", "Renaissance Engineering", "Early Philosophy", "Modern Analysis"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "17th c.", "19th c."]}	["1st c. CE — Rome → In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.","12th c. — Medieval France → In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.","16th c. — Renaissance Engineering → Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.","17th c. — Early Philosophy → By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.","19th c. — Modern Analysis → By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how what once meant leaping into danger became the mark of what stands out.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.912571	2025-10-27 18:46:12.912571
119	511	1	spelling	Arrange the letters to spell the word:	\N	elucidate	\N	10	2025-10-26 01:16:50.586084	2025-10-27 03:06:12.20211
120	527	1	spelling	Arrange the letters to spell the word:	\N	plausible	\N	10	2025-10-26 01:16:50.587531	2025-10-27 03:06:12.203577
121	542	1	spelling	Arrange the letters to spell the word:	\N	ubiquitous	\N	10	2025-10-26 01:16:50.590668	2025-10-27 03:06:12.205118
122	511	4	syn_ant_sort	Drag each word into the correct basket for 'elucidate':	{"antonyms": ["obscure", "confuse", "muddle", "bewilder", "complicate"], "synonyms": ["explain", "clarify", "illuminate", "expound", "unfold", "explicate"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.592402	2025-10-27 03:06:12.206522
124	527	4	syn_ant_sort	Drag each word into the correct basket for 'plausible':	{"antonyms": ["implausible", "incredible", "unbelievable", "absurd", "ridiculous"], "synonyms": ["credible", "believable", "reasonable", "convincing", "persuasive", "specious"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.594074	2025-10-27 03:06:12.208288
286	56	6	story	Rebuild the full story of 'salient'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *saliēns*—'leaping, springing forth.' The poets used him for fountains, fish, the pulse of joy. To leap was to live: the verb *salīre* carried vitality itself. Salient began as motion, not metaphor.", "By the Renaissance, *saillant* in French meant 'jutting out'—a wall that leaned toward the world, a bastion pointing at the horizon. English borrowed him as an engineer's and soldier's term: the salient angle of a fortress, the place that struck first and was struck hardest.", "Then the leap turned inward. Philosophers and rhetoricians called an idea 'salient' when it sprang to the mind. The fortification became a thought: something projecting beyond the rest. To leap became to signify.", "By the modern age, Salient had settled into analysis and argument. He no longer moved; he marked. To be salient was to stand out by design, not by motion. Yet in every use, his ancient spring survives—the mind's leap made permanent in language.", "He was adopted by Carolingian architects to describe cathedral spires.", "He became the motto of medieval knights celebrating chivalric valor.", "He symbolized the romantic ideal of spontaneous inspiration."], "settings": ["Rome", "Renaissance Architecture", "Early Philosophy", "Modern Analysis", "Carolingian Empire", "Medieval Courts", "Romantic Poetry"], "red_herrings": ["He was adopted by Carolingian architects to describe cathedral spires— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding ", "He became the motto of medieval knights celebrating chivalric valor— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance", "He symbolized the romantic ideal of spontaneous inspiration— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers o"], "time_periods": ["1st c. CE", "16th c.", "17th c.", "19th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *saliēns*—'leaping, springing forth.' The poets used him for fountains, fish, the pulse of joy. To leap was to live: the verb *salīre* carried vitality itself. Salient began as motion, not metaphor.","16th c. — Renaissance Architecture → By the Renaissance, *saillant* in French meant 'jutting out'—a wall that leaned toward the world, a bastion pointing at the horizon. English borrowed him as an engineer's and soldier's term: the salient angle of a fortress, the place that struck first and was struck hardest.","17th c. — Early Philosophy → Then the leap turned inward. Philosophers and rhetoricians called an idea 'salient' when it sprang to the mind. The fortification became a thought: something projecting beyond the rest. To leap became to signify.","19th c. — Modern Analysis → By the modern age, Salient had settled into analysis and argument. He no longer moved; he marked. To be salient was to stand out by design, not by motion. Yet in every use, his ancient spring survives—the mind's leap made permanent in language."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.913336	2025-10-27 18:46:12.913336
287	42	1	spelling	Spell the word 'scattershot'	\N	"scattershot"	\N	5	2025-10-27 18:46:12.916028	2025-10-27 18:46:12.916028
288	42	2	typing	Type the word 'scattershot'	\N	"scattershot"	\N	8	2025-10-27 18:46:12.917216	2025-10-27 18:46:12.917216
289	42	3	definition	What does 'scattershot' mean?	{"correct_answers": ["lacking focus or organization; covering many things in a random or haphazard way."], "incorrect_answers": ["targeted", "systematic", "methodical"]}	"lacking focus or organization; covering many things in a random or haphazard way."	\N	12	2025-10-27 18:46:12.917854	2025-10-27 18:46:12.917854
290	42	4	synonym	Select the synonyms of 'scattershot'	{"antonyms": ["targeted", "systematic", "methodical", "precise", "focused"], "synonyms": ["haphazard", "indiscriminate", "unfocused", "broad-brush", "random"], "red_herrings": ["targeted", "systematic", "methodical", "precise"]}	["haphazard","indiscriminate","unfocused","broad-brush","random"]	\N	15	2025-10-27 18:46:12.918493	2025-10-27 18:46:12.918493
291	42	5	story	Match each time period with its stage in the story of 'scattershot', then arrange them in order:	{"turns": ["In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.", "After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.", "Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."], "settings": ["American Frontier", "Postwar Era", "Digital Age"], "time_periods": ["19th c.", "20th c.", "21st c."]}	["19th c. — American Frontier → In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.","20th c. — Postwar Era → After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.","21st c. — Digital Age → Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how tools of precision become metaphors for chaos when control fails.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.919138	2025-10-27 18:46:12.919138
292	42	6	story	Rebuild the full story of 'scattershot'—beware the two false centuries. Conquer the beast for double silk.	{"turns": ["In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.", "After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.", "Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once.", "He was adopted by Renaissance artists to describe experimental painting techniques.", "He symbolized the Enlightenment ideal of spreading knowledge widely."], "settings": ["American Frontier", "Postwar Era", "Digital Age", "Renaissance", "Enlightenment"], "red_herrings": ["He was adopted by Renaissance artists to describe experimental painting techniques— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning.", "He symbolized the Enlightenment ideal of spreading knowledge widely— Her influence grew through the centuries, shaping how thinkers understood this concept. Medieval scholars built upon these foundations, adding layers of interpretation that deepened her meaning. Renaissance philosophers "], "time_periods": ["19th c.", "20th c.", "21st c.", "16th c.", "18th c."]}	["19th c. — American Frontier → In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.","20th c. — Postwar Era → After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.","21st c. — Digital Age → Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.921308	2025-10-27 18:46:12.921308
293	187	1	spelling	Spell the word 'verisimilitude'	\N	"verisimilitude"	\N	5	2025-10-27 18:46:12.922546	2025-10-27 18:46:12.922546
294	187	2	typing	Type the word 'verisimilitude'	\N	"verisimilitude"	\N	8	2025-10-27 18:46:12.92392	2025-10-27 18:46:12.92392
295	187	3	definition	What does 'verisimilitude' mean?	{"correct_answers": ["the appearance or quality of being true or real; the quality of seeming to be true."], "incorrect_answers": ["implausibility", "incredibility", "unreality"]}	"the appearance or quality of being true or real; the quality of seeming to be true."	\N	12	2025-10-27 18:46:12.92457	2025-10-27 18:46:12.92457
95	443	2	typing	Type the word you just arranged:	\N	(?i)^attest$	\N	10	2025-10-26 01:16:50.55461	2025-10-27 03:06:12.169097
296	187	4	synonym	Select the synonyms of 'verisimilitude'	{"antonyms": ["implausibility", "incredibility", "unreality", "falseness"], "synonyms": ["plausibility", "believability", "realism", "authenticity", "credibility"], "red_herrings": ["implausibility", "incredibility", "unreality", "falseness"]}	["plausibility","believability","realism","authenticity","credibility"]	\N	15	2025-10-27 18:46:12.9252	2025-10-27 18:46:12.9252
297	187	5	story	Match each time period with its stage in the story of 'verisimilitude', then arrange them in order:	{"turns": ["In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.", "When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.", "In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.", "The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.", "In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits."], "settings": ["Rome", "Medieval Poetics", "Rise of the Novel", "Realist Movement", "Modern Media"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "20th c."]}	["1st c. CE — Rome → In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.","14th c. — Medieval Poetics → When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.","17th c. — Rise of the Novel → In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.","19th c. — Realist Movement → The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.","20th c. — Modern Media → In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how truthlikeness moved from rhetoric to craft to conscience.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.925924	2025-10-27 18:46:12.925924
298	187	6	story	Rebuild the full story of 'verisimilitude'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.", "When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.", "In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.", "The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.", "In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits.", "She was embraced by Carolingian scholars who believed divine truth required only superficial resemblance to earthly experience—where the appearance of piety mattered more than genuine holiness. In their theological treatises, she represented the dangerous blurring of imitation and reality. Her influence grew through the centuries, shaping how thinkers und", "She became central to scholastic debates where perfect imitation of theological models proved spiritual authenticity—where verisimilitude to divine examples became the measure of human virtue. Medieval theologians used her to describe the paradox of seeking truth through resemblance.", "She symbolized Renaissance art's ultimate goal: creating works indistinguishable from reality itself—where verisimilitude became the highest aesthetic achievement, even when truth and artifice could no longer be distinguished. Artists sought to paint grapes so lifelike that birds would try to eat them. The Renaissance ideal of perfect"], "settings": ["Rome", "Medieval Poetics", "Rise of the Novel", "Realist Movement", "Modern Media", "Carolingian Empire", "Scholastic Theology", "Renaissance Art"], "red_herrings": ["She was embraced by Carolingian scholars who believed divine truth required only superficial resemblance to earthly experience—where the appearance of piety mattered more than genuine holiness. In their theological treatises, she represented the dangerous blurring of imitation and reality. Her influence grew through the centuries, shaping how thinkers und", "She became central to scholastic debates where perfect imitation of theological models proved spiritual authenticity—where verisimilitude to divine examples became the measure of human virtue. Medieval theologians used her to describe the paradox of seeking truth through resemblance.", "She symbolized Renaissance art's ultimate goal: creating works indistinguishable from reality itself—where verisimilitude became the highest aesthetic achievement, even when truth and artifice could no longer be distinguished. Artists sought to paint grapes so lifelike that birds would try to eat them. The Renaissance ideal of perfect"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "16th c."]}	["1st c. CE — Rome → In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.","14th c. — Medieval Poetics → When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.","17th c. — Rise of the Novel → In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.","19th c. — Realist Movement → The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.","20th c. — Modern Media → In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.926737	2025-10-27 18:46:12.926737
299	443	1	spelling	Arrange the letters to spell the word:	\N	"attest"	\N	10	2025-10-27 18:46:12.929252	2025-10-27 18:46:12.929252
300	443	2	typing	Type the word you just arranged:	\N	"(?i)^attest$"	\N	10	2025-10-27 18:46:12.929996	2025-10-27 18:46:12.929996
301	443	3	definition	Select all definitions that accurately describe 'attest':	\N	\N	{"feedback": {"fail": "Some hid what should be seen.", "hint": "Think of standing with truth.", "success": "You witnessed what matters."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.93127	2025-10-27 18:46:12.93127
302	443	4	syn_ant_sort	Drag each word into the correct basket for 'attest':	{"antonyms": ["deny", "refute", "dispute", "contradict"], "synonyms": ["testify", "verify", "confirm", "certify"], "red_herrings": ["witness", "statement", "claim", "affirm"]}	\N	{"feedback": {"fail": "Some landed in the wrong court.", "hint": "Listen for truth vs. falsehood.", "success": "You separated the witnesses from the deniers."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.931895	2025-10-27 18:46:12.931895
303	443	5	story_reorder	Match each time period with its stage in the story of 'attest', then arrange them in order:	{"turns": ["In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.", "When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age"], "red_herrings": ["He was forgotten during the Middle Ages.", "He gained magical powers in the Renaissance."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c."]}	["1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how witness became document.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.932532	2025-10-27 18:46:12.932532
304	443	6	story	Rebuild the full story of 'attest'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *testare*—'to bear witness.' Built from *testis*, the witness who stands by to see. The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying. To attest was to put your body in the way of truth—to stand where you had been and speak what you had seen. It was physical presence made vocal.", "When English courts took shape, Attest crossed from Old French *attester*. He carried the stamp of formality. Deeds were attested by witnesses; charters bore attestations from clerks. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink. Attest became the bridge between seeing and lasting: what the eye witnessed, the document preserved.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts; naturalists to species. But as print multiplied voices, attest began to carry doubt. To attest was not just to affirm but to stake one's name on it. The word learned the weight of reputation—the risk of being wrong in public, for all to see.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills and qualifications. He had passed from the drama of the courtroom to the routine of the office. The standing witness became a form to sign, a seal to affix. What began as the body's truth had become the system's record.", "He was adopted by Carolingian notaries to record the oaths of vassals—where the spoken promise of fealty became the inked contract of allegiance. In the imperial courts, he represented the sacred transformation of voice into record, making loyalty visible and permanent.", "He became the voice of Viking skalds bearing witness to heroic deeds in their longship songs—where the witness stood on shifting seas and sang what could not be forgotten. Norse poets used him to name the duty of memory that outlasted kingdoms.", "He symbolized the humanist ideal of testimony as intellectual virtue—where scholars and translators attested to the truth of recovered classical texts, making ancient voices speak again through sworn fidelity to their meaning."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age", "Carolingian Empire", "Viking Invasions", "Renaissance Humanism"], "red_herrings": ["He was adopted by Carolingian notaries to record the oaths of vassals—where the spoken promise of fealty became the inked contract of allegiance. In the imperial courts, he represented the sacred transformation of voice into record, making loyalty visible and permanent.", "He became the voice of Viking skalds bearing witness to heroic deeds in their longship songs—where the witness stood on shifting seas and sang what could not be forgotten. Norse poets used him to name the duty of memory that outlasted kingdoms.", "He symbolized the humanist ideal of testimony as intellectual virtue—where scholars and translators attested to the truth of recovered classical texts, making ancient voices speak again through sworn fidelity to their meaning."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "8th c.", "11th c.", "16th c."]}	["1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' Built from *testis*, the witness who stands by to see. The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying. To attest was to put your body in the way of truth—to stand where you had been and speak what you had seen. It was physical presence made vocal.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French *attester*. He carried the stamp of formality. Deeds were attested by witnesses; charters bore attestations from clerks. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink. Attest became the bridge between seeing and lasting: what the eye witnessed, the document preserved.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts; naturalists to species. But as print multiplied voices, attest began to carry doubt. To attest was not just to affirm but to stake one's name on it. The word learned the weight of reputation—the risk of being wrong in public, for all to see.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills and qualifications. He had passed from the drama of the courtroom to the routine of the office. The standing witness became a form to sign, a seal to affix. What began as the body's truth had become the system's record."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.93376	2025-10-27 18:46:12.93376
305	511	1	spelling	Arrange the letters to spell the word:	\N	"elucidate"	\N	10	2025-10-27 18:46:12.934576	2025-10-27 18:46:12.934576
306	511	2	typing	Type the word you just arranged:	\N	"(?i)^elucidate$"	\N	10	2025-10-27 18:46:12.935173	2025-10-27 18:46:12.935173
307	511	3	definition	Select all definitions that accurately describe 'elucidate':	\N	\N	{"feedback": {"fail": "Some definitions were missed.", "hint": "Think carefully about elucidate", "success": "You understood correctly."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.935785	2025-10-27 18:46:12.935785
308	511	4	syn_ant_sort	Drag each word into the correct basket for 'elucidate':	{"antonyms": ["obscure", "confuse", "muddle", "bewilder", "complicate"], "synonyms": ["explain", "clarify", "illuminate", "expound", "unfold", "explicate"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.93648	2025-10-27 18:46:12.93648
309	511	5	story_reorder	Match each time period with its stage in the story of 'elucidate', then arrange them in order:	{"story_texts": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was ...", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'t...", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, histor...", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is st..."], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c."]}	["1th c.","16th c.","18th c.","20th c."]	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.937144	2025-10-27 18:46:12.937144
310	511	6	story	Rebuild the full story of 'elucidate'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."], "settings": ["Setting 1th c.", "Setting 16th c.", "Setting 18th c.", "Setting 20th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["He was adopted by Carolingian scholars to illuminate sacred manuscripts—where *lūcidus* described the golden ink that made divine texts visible across the darkened scriptoria. In their theological commentaries, he represented the brightness that revealed God's word to human eyes, where illumination of scripture became a sacred act that", "He became central to scholastic debates where clarity was the highest virtue—where *ēlūcidāre* meant to untangle the knots of Aristotle's logic. Medieval philosophers used him to describe the intellectual light that transformed confusion into understanding, making the obscure suddenly obvious as abstract concepts", "He symbolized the Renaissance ideal of seeing through deception—where enlightenment meant recognizing truth beneath the layers of medieval darkness. Humanist scholars used him to name the moment when classical wisdom once again became visible to the modern world, piercing through centuries of scholarly obfuscation."], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c.", "8th c.", "12th c.", "15th c."]}	["1th c. — Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception. → In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.","16th c. — Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations. → When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.","18th c. — Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation. → In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.","20th c. — Modern educational and analytical discourse where explanation has become routine institutional practice. → Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.937876	2025-10-27 18:46:12.937876
311	469	1	spelling	Arrange the letters to spell the word:	\N	"lumbering"	\N	10	2025-10-27 18:46:12.938607	2025-10-27 18:46:12.938607
312	469	2	typing	Type the word you just arranged:	\N	"(?i)^lumbering$"	\N	10	2025-10-27 18:46:12.939219	2025-10-27 18:46:12.939219
313	469	3	definition	Select all definitions that accurately describe 'lumbering':	\N	\N	{"feedback": {"fail": "Some moved too lightly.", "hint": "Think of weight made movement.", "success": "You felt the earth shake."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.940416	2025-10-27 18:46:12.940416
314	469	4	syn_ant_sort	Drag each word into the correct basket for 'lumbering':	{"antonyms": ["graceful", "agile", "nimble", "elegant"], "synonyms": ["clumsy", "awkward", "plodding", "ungainly"], "red_herrings": ["heavy", "slow", "large", "big"]}	\N	{"feedback": {"fail": "Some landed in the wrong gait.", "hint": "Listen for weight vs. lightness.", "success": "You separated the heavy from the light-footed."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.941034	2025-10-27 18:46:12.941034
315	469	5	story_reorder	Match each time period with its stage in the story of 'lumbering', then arrange them in order:	{"turns": ["From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution"], "red_herrings": ["He was never used for animals.", "He started as a dance term."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c."]}	["14th c. — Medieval Trade → From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how goods became weight.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.942716	2025-10-27 18:46:12.942716
137	443	2	typing	Type the word you just arranged:	\N	(?i)^attest$	\N	10	2025-10-27 02:56:18.948178	2025-10-27 03:06:12.169097
104	469	1	spelling	Arrange the letters to spell the word:	\N	lumbering	\N	10	2025-10-26 01:16:50.569497	2025-10-27 03:06:12.184784
136	443	1	spelling	Arrange the letters to spell the word:	\N	attest	\N	10	2025-10-27 02:56:18.942878	2025-10-27 03:06:12.166754
105	469	2	typing	Type the word you just arranged:	\N	(?i)^lumbering$	\N	10	2025-10-26 01:16:50.570666	2025-10-27 03:06:12.185774
106	469	3	definition	Select all definitions that accurately describe 'lumbering':	{"correct_answers": ["Moving in a slow, heavy, awkward way", "Characterized by ponderous or clumsy movement", "Making a heavy, thudding sound when moving", "Ungainly or unwieldy in motion"], "incorrect_answers": ["Moving with grace and elegance", "Light and nimble in motion", "Quick and agile movement", "Smooth and fluid gestures", "Delicate and refined motion", "Swift and effortless action", "Flexible and supple movement", "Graceful and coordinated steps"]}	\N	{"feedback": {"fail": "Some moved too lightly.", "hint": "Think of weight made movement.", "success": "You felt the earth shake."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.571614	2025-10-27 03:06:12.186774
107	469	4	syn_ant_sort	Drag each word into the correct basket for 'lumbering':	{"antonyms": ["graceful", "agile", "nimble", "elegant"], "synonyms": ["clumsy", "awkward", "plodding", "ungainly"], "red_herrings": ["heavy", "slow", "large", "big"]}	\N	{"feedback": {"fail": "Some landed in the wrong gait.", "hint": "Listen for weight vs. lightness.", "success": "You separated the heavy from the light-footed."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.573026	2025-10-27 03:06:12.188025
109	483	1	spelling	Arrange the letters to spell the word:	\N	scurry	\N	10	2025-10-26 01:16:50.574793	2025-10-27 03:06:12.190986
110	483	2	typing	Type the word you just arranged:	\N	(?i)^scurry$	\N	10	2025-10-26 01:16:50.575521	2025-10-27 03:06:12.191926
111	483	3	definition	Select all definitions that accurately describe 'scurry':	{"correct_answers": ["To move hurriedly with short, quick steps", "To rush about busily in a somewhat frantic manner", "To dash or dart quickly", "To hurry with nervous or anxious energy"], "incorrect_answers": ["To move slowly and deliberately", "To walk with dignity and purpose", "To proceed in a calm, measured way", "To march with determination", "To stroll leisurely", "To amble without urgency", "To move with confidence and grace", "To travel at a steady, relaxed pace"]}	\N	{"feedback": {"fail": "Some moved too slowly.", "hint": "Think of small, urgent feet.", "success": "You caught the quick dash."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.576237	2025-10-27 03:06:12.192867
112	483	4	syn_ant_sort	Drag each word into the correct basket for 'scurry':	{"antonyms": ["amble", "saunter", "stroll", "linger"], "synonyms": ["hurry", "dash", "scuttle", "rush"], "red_herrings": ["run", "walk", "move", "go"]}	\N	{"feedback": {"fail": "Some landed at the wrong pace.", "hint": "Listen for haste vs. leisure.", "success": "You separated the hurried from the unhurried."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.576981	2025-10-27 03:06:12.194227
114	496	1	spelling	Arrange the letters to spell the word:	\N	steadfast	\N	10	2025-10-26 01:16:50.580274	2025-10-27 03:06:12.196892
115	496	2	typing	Type the word you just arranged:	\N	(?i)^steadfast$	\N	10	2025-10-26 01:16:50.581052	2025-10-27 03:06:12.197778
116	496	3	definition	Select all definitions that accurately describe 'steadfast':	{"correct_answers": ["Firmly fixed in purpose, loyalty, or faith", "Resolutely unwavering in commitment", "Constant and dependable in nature", "Steady and firm in position or belief"], "incorrect_answers": ["Changeable and unreliable", "Unsteady and wavering", "Inconsistent and fickle", "Unstable and uncertain", "Flexible to the point of weakness", "Indecisive and hesitant", "Vacillating and uncertain", "Uncommitted and half-hearted"]}	\N	{"feedback": {"fail": "Some fell where they should stand.", "hint": "Think of the unmovable.", "success": "You found what does not break."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.581908	2025-10-27 03:06:12.198813
117	496	4	syn_ant_sort	Drag each word into the correct basket for 'steadfast':	{"antonyms": ["fickle", "wavering", "unreliable", "inconstant"], "synonyms": ["loyal", "faithful", "constant", "resolute"], "red_herrings": ["strong", "firm", "steady", "solid"]}	\N	{"feedback": {"fail": "Some landed in the wrong camp.", "hint": "Listen for constancy vs. change.", "success": "You separated the faithful from the faithless."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.582636	2025-10-27 03:06:12.199978
316	469	6	story	Rebuild the full story of 'lumbering'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["From Lombard merchants came *lumber*—'pawn,' goods stored in a Lombard's shop. To lumber a room meant to fill it with stored things, cluttering the space. Lumber became the word for awkward bulk: furniture too big for doorways, objects blocking the way. He began as commerce and ended as obstruction. The slow merchant's stock became the slow creature's gait.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily. The word that named stored goods now named fallen trees. Merchants' stockrooms and loggers' rivers both held the same quality: things too heavy to move with grace. Bulk became movement—the awkward hauling of weight.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk. Not graceful movement but the honest gait of mass: each step deliberate, ground-giving, leaving prints too deep to fill. He became the poetry of weight—not beautiful but true, not fast but certain.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines that shook the earth. The term that once named awkward creatures now named industrial power. Modernity was big, loud, heavy, slow to start but impossible to stop once moving. Lumbering became the sound of progress itself—cumbersome but inevitable, awkward but unstoppable.", "He was carried by Crusader caravans—where lumbering beasts hauled siege engines across desolate landscapes toward the walls of holy cities. Chroniclers wrote of how the massive engines lumbered forward like moving fortresses, shaking the earth with their advance.", "He became the rhythm of Renaissance warehouses—where Italian merchants lumbered goods from ship to stall in chaotic loading docks. The sound of heavy crates being lumbered through narrow passages echoed through Mediterranean ports.", "He symbolized the heroic burden of explorers who lumbered through unmapped wilderness—bearing impossible loads of supplies and equipment into unknown territories, where every step was a conquest of distance and weight."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution", "Crusader Kingdoms", "Renaissance Commerce", "Age of Discovery"], "red_herrings": ["He was carried by Crusader caravans—where lumbering beasts hauled siege engines across desolate landscapes toward the walls of holy cities. Chroniclers wrote of how the massive engines lumbered forward like moving fortresses, shaking the earth with their advance.", "He became the rhythm of Renaissance warehouses—where Italian merchants lumbered goods from ship to stall in chaotic loading docks. The sound of heavy crates being lumbered through narrow passages echoed through Mediterranean ports.", "He symbolized the heroic burden of explorers who lumbered through unmapped wilderness—bearing impossible loads of supplies and equipment into unknown territories, where every step was a conquest of distance and weight."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c.", "12th c.", "15th c.", "17th c."]}	["14th c. — Medieval Trade → From Lombard merchants came *lumber*—'pawn,' goods stored in a Lombard's shop. To lumber a room meant to fill it with stored things, cluttering the space. Lumber became the word for awkward bulk: furniture too big for doorways, objects blocking the way. He began as commerce and ended as obstruction. The slow merchant's stock became the slow creature's gait.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily. The word that named stored goods now named fallen trees. Merchants' stockrooms and loggers' rivers both held the same quality: things too heavy to move with grace. Bulk became movement—the awkward hauling of weight.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk. Not graceful movement but the honest gait of mass: each step deliberate, ground-giving, leaving prints too deep to fill. He became the poetry of weight—not beautiful but true, not fast but certain.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines that shook the earth. The term that once named awkward creatures now named industrial power. Modernity was big, loud, heavy, slow to start but impossible to stop once moving. Lumbering became the sound of progress itself—cumbersome but inevitable, awkward but unstoppable."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.943448	2025-10-27 18:46:12.943448
317	457	1	spelling	Arrange the letters to spell the word:	\N	"pall"	\N	10	2025-10-27 18:46:12.944196	2025-10-27 18:46:12.944196
318	457	2	typing	Type the word you just arranged:	\N	"(?i)^pall$"	\N	10	2025-10-27 18:46:12.944823	2025-10-27 18:46:12.944823
319	457	3	definition	Select all definitions that accurately describe 'pall':	\N	\N	{"feedback": {"fail": "Some shone too brightly.", "hint": "Think of what covers and darkens.", "success": "You felt the weight of gloom."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.945913	2025-10-27 18:46:12.945913
320	457	4	syn_ant_sort	Drag each word into the correct basket for 'pall':	{"antonyms": ["brightness", "cheer", "joy", "lightness"], "synonyms": ["shroud", "gloom", "melancholy", "cloud"], "red_herrings": ["cloth", "covering", "veil", "cover"]}	\N	{"feedback": {"fail": "Some landed in the wrong light.", "hint": "Listen for dark vs. light.", "success": "You separated the shadows from the sun."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.946537	2025-10-27 18:46:12.946537
321	457	5	story_reorder	Match each time period with its stage in the story of 'pall', then arrange them in order:	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature"], "red_herrings": ["He was always a verb of excitement.", "He disappeared completely in the 16th century."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	["9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how cloth became weariness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.947181	2025-10-27 18:46:12.947181
322	457	6	story	Rebuild the full story of 'pall'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk. He was luxury before he was sorrow. But cloth is born to cover, and what it covers changes its nature. By the time Middle English spoke his name, he had learned to shield the face of death.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins—black wool for the poor, velvet for the rich, but always the same shield between the living and what they buried. He became the ritual cloth of separation: what the eye could not bear to see, he hid. From rich cloak to funeral shroud, luxury became dignity in death.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He had learned to stretch—no longer just cloth but anything heavy, dark, settling. The metaphorical pall became more common than the literal one. He became atmosphere: the feeling of weight that comes from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. The same cloth that covered death now covered enjoyment. Not shock but weariness. Not grief but boredom. He had learned a new skill: the gentle killing of interest, the slow burial of what once delighted. The covering that hid death also muffled life.", "He was woven by Carolingian nuns as the veil for relics—where the sacred cloth shielded mortal remains from mortal sight, creating a boundary between the temporal and eternal. In monastery scriptoria, he represented the mystery of what lives beyond the body.", "He became the standard of Crusader knights—where black silk marked the deathless crusade against infidel lands, transforming personal grief into divine mission. Chroniclers recorded how he flew over battlefields as both promise and memorial.", "He symbolized the Romantic shroud of melancholy that covered the artist's soul—making sorrow into aesthetic beauty, where creative genius found its voice in the language of loss and longing that could not be expressed in cheer."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature", "Carolingian Empire", "Crusader States", "Romantic Movement"], "red_herrings": ["He was woven by Carolingian nuns as the veil for relics—where the sacred cloth shielded mortal remains from mortal sight, creating a boundary between the temporal and eternal. In monastery scriptoria, he represented the mystery of what lives beyond the body.", "He became the standard of Crusader knights—where black silk marked the deathless crusade against infidel lands, transforming personal grief into divine mission. Chroniclers recorded how he flew over battlefields as both promise and memorial.", "He symbolized the Romantic shroud of melancholy that covered the artist's soul—making sorrow into aesthetic beauty, where creative genius found its voice in the language of loss and longing that could not be expressed in cheer."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c.", "7th c.", "12th c.", "18th c."]}	["9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk. He was luxury before he was sorrow. But cloth is born to cover, and what it covers changes its nature. By the time Middle English spoke his name, he had learned to shield the face of death.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins—black wool for the poor, velvet for the rich, but always the same shield between the living and what they buried. He became the ritual cloth of separation: what the eye could not bear to see, he hid. From rich cloak to funeral shroud, luxury became dignity in death.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He had learned to stretch—no longer just cloth but anything heavy, dark, settling. The metaphorical pall became more common than the literal one. He became atmosphere: the feeling of weight that comes from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. The same cloth that covered death now covered enjoyment. Not shock but weariness. Not grief but boredom. He had learned a new skill: the gentle killing of interest, the slow burial of what once delighted. The covering that hid death also muffled life."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.947891	2025-10-27 18:46:12.947891
323	527	1	spelling	Arrange the letters to spell the word:	\N	"plausible"	\N	10	2025-10-27 18:46:12.948609	2025-10-27 18:46:12.948609
324	527	2	typing	Type the word you just arranged:	\N	"(?i)^plausible$"	\N	10	2025-10-27 18:46:12.949253	2025-10-27 18:46:12.949253
325	527	3	definition	Select all definitions that accurately describe 'plausible':	\N	\N	{"feedback": {"fail": "Some definitions were missed.", "hint": "Think carefully about plausible", "success": "You understood correctly."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.949869	2025-10-27 18:46:12.949869
326	527	4	syn_ant_sort	Drag each word into the correct basket for 'plausible':	{"antonyms": ["implausible", "incredible", "unbelievable", "absurd", "ridiculous"], "synonyms": ["credible", "believable", "reasonable", "convincing", "persuasive", "specious"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.950552	2025-10-27 18:46:12.950552
327	527	5	story_reorder	Match each time period with its stage in the story of 'plausible', then arrange them in order:	{"story_texts": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she name...", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still aske...", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask...", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in..."], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c."]}	["1th c.","17th c.","19th c.","20th c."]	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.951198	2025-10-27 18:46:12.951198
328	527	6	story	Rebuild the full story of 'plausible'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."], "settings": ["Setting 1th c.", "Setting 17th c.", "Setting 19th c.", "Setting 20th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["She was embraced by scholastic philosophers who believed truth required universal consensus—where *plaudibilis* became the measure of what all reasonable minds must accept. Medieval theologians used her to describe the shared judgment that distinguished truth from heresy, where plausibility emerged from the Her reputa", "She became the standard of chivalric courts where public approval measured virtue—where the applause of nobles proved the knight's worth. In the tournament grounds, she represented the collective judgment that turned individual deeds into lasting reputation, where the knight's character was measured not by", "She symbolized the Renaissance humanist's faith in public debate—where plausibility emerged from the free exchange of ideas. Philosophers believed that what could survive open scrutiny was, by definition, worthy of belief—the applause of the forum became the test of truth, where intellectual discourse determined what ideas deserved"], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "15th c."]}	["1th c. — Roman rhetorical and theatrical culture where audience approval measured persuasive success. → In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.","17th c. — Enlightenment philosophy and probability theory distinguishing appearance from certainty. → When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.","19th c. — Victorian social codes emphasizing proper appearance and public respectability. → Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.","20th c. — Modern discourse where persuasive presentation competes with factual verification. → Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.951861	2025-10-27 18:46:12.951861
329	483	1	spelling	Arrange the letters to spell the word:	\N	"scurry"	\N	10	2025-10-27 18:46:12.953446	2025-10-27 18:46:12.953446
330	483	2	typing	Type the word you just arranged:	\N	"(?i)^scurry$"	\N	10	2025-10-27 18:46:12.955375	2025-10-27 18:46:12.955375
331	483	3	definition	Select all definitions that accurately describe 'scurry':	\N	\N	{"feedback": {"fail": "Some moved too slowly.", "hint": "Think of small, urgent feet.", "success": "You caught the quick dash."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.956063	2025-10-27 18:46:12.956063
332	483	4	syn_ant_sort	Drag each word into the correct basket for 'scurry':	{"antonyms": ["amble", "saunter", "stroll", "linger"], "synonyms": ["hurry", "dash", "scuttle", "rush"], "red_herrings": ["run", "walk", "move", "go"]}	\N	{"feedback": {"fail": "Some landed at the wrong pace.", "hint": "Listen for haste vs. leisure.", "success": "You separated the hurried from the unhurried."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.956728	2025-10-27 18:46:12.956728
333	483	5	story_reorder	Match each time period with its stage in the story of 'scurry', then arrange them in order:	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age"], "red_herrings": ["He was invented in the 21st century.", "He never described animal movement."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c."]}	["17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how small became busy.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.957975	2025-10-27 18:46:12.957975
334	483	6	story	Rebuild the full story of 'scurry'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out. He named the flustered gait of urgency, the movement of those who must arrive without knowing why. From hurry came scurry: not just speed but the anxious speed of small creatures before larger ones.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs; ants scurried along paths. He became the verb of small haste: not the bold rush of hunters but the furtive dash of the hunted. He carried the sound of small feet on hard ground—the audible anxiety of creatures too small to stand their ground.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness. But scale mattered: to scurry was not to stride but to dart, not to march but to scoot. It suggested movement without dignity—hurried but not powerful, busy but not significant. The small creature's flight became the worker's pace.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news; attention itself scurried from device to device. The verb of small movement became the verb of modern distraction: never still, never settled, always moving to the next thing. What began as flight became habit—the perpetual hurry of being that cannot stop.", "He was carried by minstrels scurrying through medieval castles—where performers rushed between courts seeking patronage, their hurrying feet carrying songs and stories from one great hall to the next in the perpetual dance of courtly service.", "He became the secret language of spies scurrying through Renaissance cities—gathering intelligence in the shadows of power, where every hurried movement carried the weight of state secrets and political survival.", "He symbolized the enlightened citizen scurrying between coffee houses and salons—where ideas traveled faster than people, and the new public sphere was built on the hurried circulation of printed words and spoken debate."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age", "Medieval Courts", "Renaissance Households", "Enlightenment Society"], "red_herrings": ["He was carried by minstrels scurrying through medieval castles—where performers rushed between courts seeking patronage, their hurrying feet carrying songs and stories from one great hall to the next in the perpetual dance of courtly service.", "He became the secret language of spies scurrying through Renaissance cities—gathering intelligence in the shadows of power, where every hurried movement carried the weight of state secrets and political survival.", "He symbolized the enlightened citizen scurrying between coffee houses and salons—where ideas traveled faster than people, and the new public sphere was built on the hurried circulation of printed words and spoken debate."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c.", "15th c.", "16th c.", "18th c."]}	["17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out. He named the flustered gait of urgency, the movement of those who must arrive without knowing why. From hurry came scurry: not just speed but the anxious speed of small creatures before larger ones.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs; ants scurried along paths. He became the verb of small haste: not the bold rush of hunters but the furtive dash of the hunted. He carried the sound of small feet on hard ground—the audible anxiety of creatures too small to stand their ground.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness. But scale mattered: to scurry was not to stride but to dart, not to march but to scoot. It suggested movement without dignity—hurried but not powerful, busy but not significant. The small creature's flight became the worker's pace.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news; attention itself scurried from device to device. The verb of small movement became the verb of modern distraction: never still, never settled, always moving to the next thing. What began as flight became habit—the perpetual hurry of being that cannot stop."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.96024	2025-10-27 18:46:12.96024
335	496	1	spelling	Arrange the letters to spell the word:	\N	"steadfast"	\N	10	2025-10-27 18:46:12.960963	2025-10-27 18:46:12.960963
336	496	2	typing	Type the word you just arranged:	\N	"(?i)^steadfast$"	\N	10	2025-10-27 18:46:12.961689	2025-10-27 18:46:12.961689
337	496	3	definition	Select all definitions that accurately describe 'steadfast':	\N	\N	{"feedback": {"fail": "Some fell where they should stand.", "hint": "Think of the unmovable.", "success": "You found what does not break."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.962339	2025-10-27 18:46:12.962339
338	496	4	syn_ant_sort	Drag each word into the correct basket for 'steadfast':	{"antonyms": ["fickle", "wavering", "unreliable", "inconstant"], "synonyms": ["loyal", "faithful", "constant", "resolute"], "red_herrings": ["strong", "firm", "steady", "solid"]}	\N	{"feedback": {"fail": "Some landed in the wrong camp.", "hint": "Listen for constancy vs. change.", "success": "You separated the faithful from the faithless."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.963082	2025-10-27 18:46:12.963082
339	496	5	story_reorder	Match each time period with its stage in the story of 'steadfast', then arrange them in order:	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.", "When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.", "When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy"], "red_herrings": ["He lost all meaning in the Middle Ages.", "He was invented in modern times."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	["9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how standing became staying.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 18:46:12.964282	2025-10-27 18:46:12.964282
340	496	6	story	Rebuild the full story of 'steadfast'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' *Stæd* meant a place, a standing-ground; *fæst* meant fixed. Together they named what held its spot. Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral—not yet loyalty but position, not yet faith but footing. The stone does not move, the word does not break.", "When chivalry made virtue ritual, Steadfast put on honor's colors. The knight who stood steadfast in battle stood steadfast in vows. What began as physical holding became moral holding. Fealty, faith, friendship—all required steadfastness. He learned to name not just standing but staying, not just position but persistence. The shield-wall became the oath-wall; the enemy without became the doubt within.", "When poets sang of love, they summoned him. The steadfast heart that beats one name; the steadfast gaze that never strays. He became the language of constancy—not just loyalty but devotion, not just persistence but passion that endures. What began as military courage became romantic fidelity. The standing warrior became the standing lover; the battle-line became the marriage vow.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds. In changing times, the steadfast heart stayed true; in shifting values, the steadfast mind held course. He learned the language of authenticity: not stubbornness but integrity, not rigidity but resolve. What could not be moved defined the person who chose not to move.", "He was sworn by Viking jarls who held fast to their word across seas and seasons—where honor was measured by constancy in the face of betrayal, and the steadfast heart was the only currency that survived changing alliances.", "He became the creed of Crusader knights who stood steadfast before infidel armies—where faith in God became unbreakable resolve, and the steadfast heart found its true test not in victory but in remaining true when all hope had fled.", "He symbolized the enlightened philosopher's commitment to reason—where steadfast pursuit of truth outweighed all worldly pressures, and intellectual integrity became the highest form of courage in an age of questioning."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy", "Viking Sagas", "Crusader Honor", "Enlightenment Ethics"], "red_herrings": ["He was sworn by Viking jarls who held fast to their word across seas and seasons—where honor was measured by constancy in the face of betrayal, and the steadfast heart was the only currency that survived changing alliances.", "He became the creed of Crusader knights who stood steadfast before infidel armies—where faith in God became unbreakable resolve, and the steadfast heart found its true test not in victory but in remaining true when all hope had fled.", "He symbolized the enlightened philosopher's commitment to reason—where steadfast pursuit of truth outweighed all worldly pressures, and intellectual integrity became the highest form of courage in an age of questioning."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c.", "11th c.", "13th c.", "18th c."]}	["9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' *Stæd* meant a place, a standing-ground; *fæst* meant fixed. Together they named what held its spot. Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral—not yet loyalty but position, not yet faith but footing. The stone does not move, the word does not break.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. The knight who stood steadfast in battle stood steadfast in vows. What began as physical holding became moral holding. Fealty, faith, friendship—all required steadfastness. He learned to name not just standing but staying, not just position but persistence. The shield-wall became the oath-wall; the enemy without became the doubt within.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. The steadfast heart that beats one name; the steadfast gaze that never strays. He became the language of constancy—not just loyalty but devotion, not just persistence but passion that endures. What began as military courage became romantic fidelity. The standing warrior became the standing lover; the battle-line became the marriage vow.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds. In changing times, the steadfast heart stayed true; in shifting values, the steadfast mind held course. He learned the language of authenticity: not stubbornness but integrity, not rigidity but resolve. What could not be moved defined the person who chose not to move."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.965578	2025-10-27 18:46:12.965578
341	542	1	spelling	Arrange the letters to spell the word:	\N	"ubiquitous"	\N	10	2025-10-27 18:46:12.966304	2025-10-27 18:46:12.966304
342	542	2	typing	Type the word you just arranged:	\N	"(?i)^ubiquitous$"	\N	10	2025-10-27 18:46:12.966918	2025-10-27 18:46:12.966918
156	496	1	spelling	Arrange the letters to spell the word:	\N	steadfast	\N	10	2025-10-27 02:56:18.973029	2025-10-27 03:06:12.196892
157	496	2	typing	Type the word you just arranged:	\N	(?i)^steadfast$	\N	10	2025-10-27 02:56:18.973784	2025-10-27 03:06:12.197778
158	496	3	definition	Select all definitions that accurately describe 'steadfast':	{"correct_answers": ["Firmly fixed in purpose, loyalty, or faith", "Resolutely unwavering in commitment", "Constant and dependable in nature", "Steady and firm in position or belief"], "incorrect_answers": ["Changeable and unreliable", "Unsteady and wavering", "Inconsistent and fickle", "Unstable and uncertain", "Flexible to the point of weakness", "Indecisive and hesitant", "Vacillating and uncertain", "Uncommitted and half-hearted"]}	\N	{"feedback": {"fail": "Some fell where they should stand.", "hint": "Think of the unmovable.", "success": "You found what does not break."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.974623	2025-10-27 03:06:12.198813
159	496	4	syn_ant_sort	Drag each word into the correct basket for 'steadfast':	{"antonyms": ["fickle", "wavering", "unreliable", "inconstant"], "synonyms": ["loyal", "faithful", "constant", "resolute"], "red_herrings": ["strong", "firm", "steady", "solid"]}	\N	{"feedback": {"fail": "Some landed in the wrong camp.", "hint": "Listen for constancy vs. change.", "success": "You separated the faithful from the faithless."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.975387	2025-10-27 03:06:12.199978
160	496	5	story_reorder	Match each time period with its stage in the story of 'steadfast', then arrange them in order:	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.", "When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.", "When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy"], "red_herrings": ["He lost all meaning in the Middle Ages.", "He was invented in modern times."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how standing became staying.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 02:56:18.976216	2025-10-27 03:06:12.200975
161	511	1	spelling	Arrange the letters to spell the word:	\N	elucidate	\N	10	2025-10-27 02:56:18.97761	2025-10-27 03:06:12.20211
162	527	1	spelling	Arrange the letters to spell the word:	\N	plausible	\N	10	2025-10-27 02:56:18.97892	2025-10-27 03:06:12.203577
163	542	1	spelling	Arrange the letters to spell the word:	\N	ubiquitous	\N	10	2025-10-27 02:56:18.980105	2025-10-27 03:06:12.205118
164	511	4	syn_ant_sort	Drag each word into the correct basket for 'elucidate':	{"antonyms": ["obscure", "confuse", "muddle", "bewilder", "complicate"], "synonyms": ["explain", "clarify", "illuminate", "expound", "unfold", "explicate"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.981372	2025-10-27 03:06:12.206522
343	542	3	definition	Select all definitions that accurately describe 'ubiquitous':	\N	\N	{"feedback": {"fail": "Some definitions were missed.", "hint": "Think carefully about ubiquitous", "success": "You understood correctly."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.967571	2025-10-27 18:46:12.967571
166	527	4	syn_ant_sort	Drag each word into the correct basket for 'plausible':	{"antonyms": ["implausible", "incredible", "unbelievable", "absurd", "ridiculous"], "synonyms": ["credible", "believable", "reasonable", "convincing", "persuasive", "specious"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.982899	2025-10-27 03:06:12.208288
344	542	4	syn_ant_sort	Drag each word into the correct basket for 'ubiquitous':	{"antonyms": ["rare", "scarce", "uncommon", "unusual", "absent"], "synonyms": ["omnipresent", "pervasive", "everywhere", "universal", "commonplace"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.968169	2025-10-27 18:46:12.968169
345	542	5	story_reorder	Match each time period with its stage in the story of 'ubiquitous', then arrange them in order:	{"story_texts": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing t...", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Ele...", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubi...", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, th..."], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c."]}	["17th c.","19th c.","20th c.","21th c."]	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 18:46:12.968823	2025-10-27 18:46:12.968823
346	542	6	story	Rebuild the full story of 'ubiquitous'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."], "settings": ["Setting 17th c.", "Setting 19th c.", "Setting 20th c.", "Setting 21th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["He was adopted by Carolingian mystics to describe the omnipresent divine presence that infused all creation—where *ubīque* became the name for God's simultaneous existence in every monastery stone and every breath of wind. In their contemplative texts, he represented the mystery of infinite presence within finite boundaries, where the", "He became central to medieval theories of magic and alchemy—where ubiquity was the property of substances that could exist in all places simultaneously. Alchemists sought to create the philosopher's stone that shared in divine ubiquity—a single essence distributed across all matter, where the transformation of", "He symbolized the humanist ideal of knowledge spreading universally—where the printing press made ideas ubiquitous across all European courts and universities. Renaissance scholars believed that information, like divine presence, should know no boundaries—the word of possibility made manifest in ink and paper, where knowledge"], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c.", "8th c.", "12th c.", "15th c."]}	["17th c. — Scholastic and Protestant theology concerning divine omnipresence. → In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.","19th c. — Nineteenth-century physics and metaphysics theorizing universal forces and fields. → Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.","20th c. — Mass media, advertising, and global capitalism distributing products and images universally. → Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.","21th c. — Digital technology and internet culture creating universal connectivity and constant presence. → Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 18:46:12.969612	2025-10-27 18:46:12.969612
168	542	4	syn_ant_sort	Drag each word into the correct basket for 'ubiquitous':	{"antonyms": ["rare", "scarce", "uncommon", "unusual", "absent"], "synonyms": ["omnipresent", "pervasive", "everywhere", "universal", "commonplace"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.984623	2025-10-27 03:06:12.210167
215	33	4	syn_ant_sort	Drag each word into the correct basket for 'elucidate':	{"antonyms": ["obscure", "confuse", "muddle", "bewilder", "complicate"], "synonyms": ["explain", "clarify", "illuminate", "expound", "unfold", "explicate"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.448291	2025-10-27 14:09:51.606618
96	443	3	definition	Select all definitions that accurately describe 'attest':	{"correct_answers": ["To provide clear evidence or proof of something", "To bear witness or testify to a fact", "To certify or verify as true", "To declare or affirm formally"], "incorrect_answers": ["To deny or refute something", "To hide or conceal evidence", "To remain silent about facts", "To avoid providing proof", "To contradict a statement", "To dismiss as false", "To refuse to acknowledge", "To suppress information"]}	\N	{"feedback": {"fail": "Some hid what should be seen.", "hint": "Think of standing with truth.", "success": "You witnessed what matters."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.556064	2025-10-27 03:06:12.171176
221	511	2	typing	Type the word you just arranged:	\N	(?i)^elucidate$	\N	10	2025-10-27 03:07:44.123067	2025-10-27 03:07:44.123067
222	511	3	definition	Select all definitions that accurately describe 'elucidate':	{"correct_answers": ["to make clear and explain; to shed light on something that is obscure or difficult to understand.", "To make (something) clear and understandable", "To explain or clarify in detail", "To shed light upon"], "incorrect_answers": ["obscure", "confuse", "muddle", "To avoid explanation", "To mislead or deceive", "To prevent understanding", "To keep secret", "To withhold information"]}	\N	{"min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:07:44.127554	2025-10-27 03:07:44.127554
223	527	2	typing	Type the word you just arranged:	\N	(?i)^plausible$	\N	10	2025-10-27 03:07:44.131243	2025-10-27 03:07:44.131243
224	527	3	definition	Select all definitions that accurately describe 'plausible':	{"correct_answers": ["seeming reasonable or probable; appearing worthy of belief or acceptance.", "To make (something) clear and understandable", "To explain or clarify in detail", "To shed light upon"], "incorrect_answers": ["implausible", "incredible", "unbelievable", "To avoid explanation", "To mislead or deceive", "To prevent understanding", "To keep secret", "To withhold information"]}	\N	{"min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:07:44.133	2025-10-27 03:07:44.133
225	542	2	typing	Type the word you just arranged:	\N	(?i)^ubiquitous$	\N	10	2025-10-27 03:07:44.135662	2025-10-27 03:07:44.135662
226	542	3	definition	Select all definitions that accurately describe 'ubiquitous':	{"correct_answers": ["present, appearing, or found everywhere; extremely common or widespread.", "To make (something) clear and understandable", "To explain or clarify in detail", "To shed light upon"], "incorrect_answers": ["rare", "scarce", "uncommon", "To avoid explanation", "To mislead or deceive", "To prevent understanding", "To keep secret", "To withhold information"]}	\N	{"min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:07:44.137152	2025-10-27 03:07:44.137152
138	443	3	definition	Select all definitions that accurately describe 'attest':	{"correct_answers": ["To provide clear evidence or proof of something", "To bear witness or testify to a fact", "To certify or verify as true", "To declare or affirm formally"], "incorrect_answers": ["To deny or refute something", "To hide or conceal evidence", "To remain silent about facts", "To avoid providing proof", "To contradict a statement", "To dismiss as false", "To refuse to acknowledge", "To suppress information"]}	\N	{"feedback": {"fail": "Some hid what should be seen.", "hint": "Think of standing with truth.", "success": "You witnessed what matters."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.950148	2025-10-27 03:06:12.171176
139	443	4	syn_ant_sort	Drag each word into the correct basket for 'attest':	{"antonyms": ["deny", "refute", "dispute", "contradict"], "synonyms": ["testify", "verify", "confirm", "certify"], "red_herrings": ["witness", "statement", "claim", "affirm"]}	\N	{"feedback": {"fail": "Some landed in the wrong court.", "hint": "Listen for truth vs. falsehood.", "success": "You separated the witnesses from the deniers."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.951788	2025-10-27 03:06:12.173359
140	443	5	story_reorder	Match each time period with its stage in the story of 'attest', then arrange them in order:	{"turns": ["In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.", "When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age"], "red_herrings": ["He was forgotten during the Middle Ages.", "He gained magical powers in the Renaissance."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c."]}	{"1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how witness became document.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 02:56:18.953936	2025-10-27 03:06:12.175354
98	443	5	story_reorder	Match each time period with its stage in the story of 'attest', then arrange them in order:	{"turns": ["In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.", "When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age"], "red_herrings": ["He was forgotten during the Middle Ages.", "He gained magical powers in the Renaissance."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c."]}	{"1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how witness became document.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-26 01:16:50.559327	2025-10-27 03:06:12.175354
181	28	1	spelling	Arrange the letters to spell the word:	\N	attest	\N	10	2025-10-27 03:06:33.406248	2025-10-27 14:09:51.528583
103	457	5	story_reorder	Match each time period with its stage in the story of 'pall', then arrange them in order:	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature"], "red_herrings": ["He was always a verb of excitement.", "He disappeared completely in the 16th century."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how cloth became weariness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-26 01:16:50.56805	2025-10-27 03:06:12.183388
149	469	4	syn_ant_sort	Drag each word into the correct basket for 'lumbering':	{"antonyms": ["graceful", "agile", "nimble", "elegant"], "synonyms": ["clumsy", "awkward", "plodding", "ungainly"], "red_herrings": ["heavy", "slow", "large", "big"]}	\N	{"feedback": {"fail": "Some landed in the wrong gait.", "hint": "Listen for weight vs. lightness.", "success": "You separated the heavy from the light-footed."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.966475	2025-10-27 03:06:12.188025
150	469	5	story_reorder	Match each time period with its stage in the story of 'lumbering', then arrange them in order:	{"turns": ["From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution"], "red_herrings": ["He was never used for animals.", "He started as a dance term."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c."]}	{"14th c. — Medieval Trade → From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how goods became weight.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 02:56:18.967412	2025-10-27 03:06:12.189799
108	469	5	story_reorder	Match each time period with its stage in the story of 'lumbering', then arrange them in order:	{"turns": ["From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution"], "red_herrings": ["He was never used for animals.", "He started as a dance term."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c."]}	{"14th c. — Medieval Trade → From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how goods became weight.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-26 01:16:50.573903	2025-10-27 03:06:12.189799
153	483	3	definition	Select all definitions that accurately describe 'scurry':	{"correct_answers": ["To move hurriedly with short, quick steps", "To rush about busily in a somewhat frantic manner", "To dash or dart quickly", "To hurry with nervous or anxious energy"], "incorrect_answers": ["To move slowly and deliberately", "To walk with dignity and purpose", "To proceed in a calm, measured way", "To march with determination", "To stroll leisurely", "To amble without urgency", "To move with confidence and grace", "To travel at a steady, relaxed pace"]}	\N	{"feedback": {"fail": "Some moved too slowly.", "hint": "Think of small, urgent feet.", "success": "You caught the quick dash."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.969956	2025-10-27 03:06:12.192867
154	483	4	syn_ant_sort	Drag each word into the correct basket for 'scurry':	{"antonyms": ["amble", "saunter", "stroll", "linger"], "synonyms": ["hurry", "dash", "scuttle", "rush"], "red_herrings": ["run", "walk", "move", "go"]}	\N	{"feedback": {"fail": "Some landed at the wrong pace.", "hint": "Listen for haste vs. leisure.", "success": "You separated the hurried from the unhurried."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.970839	2025-10-27 03:06:12.194227
113	483	5	story_reorder	Match each time period with its stage in the story of 'scurry', then arrange them in order:	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age"], "red_herrings": ["He was invented in the 21st century.", "He never described animal movement."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c."]}	{"17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how small became busy.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-26 01:16:50.577921	2025-10-27 03:06:12.195348
155	483	5	story_reorder	Match each time period with its stage in the story of 'scurry', then arrange them in order:	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age"], "red_herrings": ["He was invented in the 21st century.", "He never described animal movement."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c."]}	{"17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how small became busy.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 02:56:18.972247	2025-10-27 03:06:12.195348
118	496	5	story_reorder	Match each time period with its stage in the story of 'steadfast', then arrange them in order:	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.", "When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.", "When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy"], "red_herrings": ["He lost all meaning in the Middle Ages.", "He was invented in modern times."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how standing became staying.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-26 01:16:50.583456	2025-10-27 03:06:12.200975
126	542	4	syn_ant_sort	Drag each word into the correct basket for 'ubiquitous':	{"antonyms": ["rare", "scarce", "uncommon", "unusual", "absent"], "synonyms": ["omnipresent", "pervasive", "everywhere", "universal", "commonplace"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.595528	2025-10-27 03:06:12.210167
165	511	5	story_reorder	Match each time period with its stage in the story of 'elucidate', then arrange them in order:	{"turns": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."], "settings": ["Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception.", "Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations.", "Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation.", "Modern educational and analytical discourse where explanation has become routine institutional practice."], "red_herrings": [], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c."]}	["1th c. — Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception. → In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.","16th c. — Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations. → When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.","18th c. — Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation. → In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.","20th c. — Modern educational and analytical discourse where explanation has become routine institutional practice. → Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of elucidate through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.982123	2025-10-27 03:06:12.207435
186	29	1	spelling	Arrange the letters to spell the word:	\N	pall	\N	10	2025-10-27 03:06:33.416887	2025-10-27 14:09:51.543009
187	29	2	typing	Type the word you just arranged:	\N	(?i)^pall$	\N	10	2025-10-27 03:06:33.418336	2025-10-27 14:09:51.544607
188	29	3	definition	Select all definitions that accurately describe 'pall':	{"correct_answers": ["A heavy, dark cloth covering, especially for mourning", "A gloomy or depressing atmosphere", "To become dull or less interesting", "Something that spreads sadness or gloom"], "incorrect_answers": ["A bright and cheerful atmosphere", "Something that brings joy and excitement", "A feeling of lightness and freedom", "An uplifting or inspiring quality", "A celebration or festivity", "Something that energizes and motivates", "A sense of hope and optimism", "An atmosphere of happiness"]}	\N	{"feedback": {"fail": "Some shone too brightly.", "hint": "Think of what covers and darkens.", "success": "You felt the weight of gloom."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.419802	2025-10-27 14:09:51.546086
189	29	4	syn_ant_sort	Drag each word into the correct basket for 'pall':	{"antonyms": ["brightness", "cheer", "joy", "lightness"], "synonyms": ["shroud", "gloom", "melancholy", "cloud"], "red_herrings": ["cloth", "covering", "veil", "cover"]}	\N	{"feedback": {"fail": "Some landed in the wrong light.", "hint": "Listen for dark vs. light.", "success": "You separated the shadows from the sun."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.421072	2025-10-27 14:09:51.547493
191	30	1	spelling	Arrange the letters to spell the word:	\N	lumbering	\N	10	2025-10-27 03:06:33.423553	2025-10-27 14:09:51.554569
192	30	2	typing	Type the word you just arranged:	\N	(?i)^lumbering$	\N	10	2025-10-27 03:06:33.424606	2025-10-27 14:09:51.556226
193	30	3	definition	Select all definitions that accurately describe 'lumbering':	{"correct_answers": ["Moving in a slow, heavy, awkward way", "Characterized by ponderous or clumsy movement", "Making a heavy, thudding sound when moving", "Ungainly or unwieldy in motion"], "incorrect_answers": ["Moving with grace and elegance", "Light and nimble in motion", "Quick and agile movement", "Smooth and fluid gestures", "Delicate and refined motion", "Swift and effortless action", "Flexible and supple movement", "Graceful and coordinated steps"]}	\N	{"feedback": {"fail": "Some moved too lightly.", "hint": "Think of weight made movement.", "success": "You felt the earth shake."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.425604	2025-10-27 14:09:51.558934
194	30	4	syn_ant_sort	Drag each word into the correct basket for 'lumbering':	{"antonyms": ["graceful", "agile", "nimble", "elegant"], "synonyms": ["clumsy", "awkward", "plodding", "ungainly"], "red_herrings": ["heavy", "slow", "large", "big"]}	\N	{"feedback": {"fail": "Some landed in the wrong gait.", "hint": "Listen for weight vs. lightness.", "success": "You separated the heavy from the light-footed."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.426717	2025-10-27 14:09:51.56525
195	30	5	story_reorder	Match each time period with its stage in the story of 'lumbering', then arrange them in order:	{"turns": ["From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution"], "red_herrings": ["He was never used for animals.", "He started as a dance term."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c."]}	{"14th c. — Medieval Trade → From Lombard merchants came *lumber*—goods stored in shops. To lumber a room meant to fill it with stored things, cluttering the space.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines. The term that named awkward creatures now named industrial power."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how goods became weight.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 03:06:33.42777	2025-10-27 14:09:51.577474
196	31	1	spelling	Arrange the letters to spell the word:	\N	scurry	\N	10	2025-10-27 03:06:33.429136	2025-10-27 14:09:51.579217
197	31	2	typing	Type the word you just arranged:	\N	(?i)^scurry$	\N	10	2025-10-27 03:06:33.430225	2025-10-27 14:09:51.580594
199	31	4	syn_ant_sort	Drag each word into the correct basket for 'scurry':	{"antonyms": ["amble", "saunter", "stroll", "linger"], "synonyms": ["hurry", "dash", "scuttle", "rush"], "red_herrings": ["run", "walk", "move", "go"]}	\N	{"feedback": {"fail": "Some landed at the wrong pace.", "hint": "Listen for haste vs. leisure.", "success": "You separated the hurried from the unhurried."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.432381	2025-10-27 14:09:51.58472
201	32	1	spelling	Arrange the letters to spell the word:	\N	steadfast	\N	10	2025-10-27 03:06:33.434562	2025-10-27 14:09:51.589764
202	32	2	typing	Type the word you just arranged:	\N	(?i)^steadfast$	\N	10	2025-10-27 03:06:33.435463	2025-10-27 14:09:51.591227
203	32	3	definition	Select all definitions that accurately describe 'steadfast':	{"correct_answers": ["Firmly fixed in purpose, loyalty, or faith", "Resolutely unwavering in commitment", "Constant and dependable in nature", "Steady and firm in position or belief"], "incorrect_answers": ["Changeable and unreliable", "Unsteady and wavering", "Inconsistent and fickle", "Unstable and uncertain", "Flexible to the point of weakness", "Indecisive and hesitant", "Vacillating and uncertain", "Uncommitted and half-hearted"]}	\N	{"feedback": {"fail": "Some fell where they should stand.", "hint": "Think of the unmovable.", "success": "You found what does not break."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.43646	2025-10-27 14:09:51.592546
204	32	4	syn_ant_sort	Drag each word into the correct basket for 'steadfast':	{"antonyms": ["fickle", "wavering", "unreliable", "inconstant"], "synonyms": ["loyal", "faithful", "constant", "resolute"], "red_herrings": ["strong", "firm", "steady", "solid"]}	\N	{"feedback": {"fail": "Some landed in the wrong camp.", "hint": "Listen for constancy vs. change.", "success": "You separated the faithful from the faithless."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.437451	2025-10-27 14:09:51.593856
205	32	5	story_reorder	Match each time period with its stage in the story of 'steadfast', then arrange them in order:	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.", "When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.", "When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy"], "red_herrings": ["He lost all meaning in the Middle Ages.", "He was invented in modern times."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. What began as physical holding became moral holding. The shield-wall became the oath-wall.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. He became the language of constancy—not just loyalty but devotion. What began as military courage became romantic fidelity.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how standing became staying.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 03:06:33.438474	2025-10-27 14:09:51.595294
206	33	1	spelling	Arrange the letters to spell the word:	\N	elucidate	\N	10	2025-10-27 03:06:33.43971	2025-10-27 14:09:51.596744
207	33	2	typing	Type the word you just arranged:	\N	(?i)^elucidate$	\N	10	2025-10-27 03:06:33.440753	2025-10-27 14:09:51.598047
208	33	3	definition	Select all definitions that accurately describe 'elucidate':	{"correct_answers": ["To make something clear or easy to understand by explanation.", "To provide clarity and illumination on a complex or obscure subject."], "incorrect_answers": ["Wrong definition 1", "Wrong definition 2"]}	\N	{"feedback": {"fail": "Some missed the point.", "hint": "Think of elucidate", "success": "You understood."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.441686	2025-10-27 14:09:51.599305
209	34	1	spelling	Arrange the letters to spell the word:	\N	plausible	\N	10	2025-10-27 03:06:33.442553	2025-10-27 14:09:51.600499
210	34	2	typing	Type the word you just arranged:	\N	(?i)^plausible$	\N	10	2025-10-27 03:06:33.443456	2025-10-27 14:09:51.601519
211	34	3	definition	Select all definitions that accurately describe 'plausible':	{"correct_answers": ["Appearing reasonable or credible; seeming worthy of belief.", "Having the appearance of truth without necessarily being true."], "incorrect_answers": ["Wrong definition 1", "Wrong definition 2"]}	\N	{"feedback": {"fail": "Some missed the point.", "hint": "Think of plausible", "success": "You understood."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.444378	2025-10-27 14:09:51.602511
212	35	1	spelling	Arrange the letters to spell the word:	\N	ubiquitous	\N	10	2025-10-27 03:06:33.445352	2025-10-27 14:09:51.60349
213	35	2	typing	Type the word you just arranged:	\N	(?i)^ubiquitous$	\N	10	2025-10-27 03:06:33.446417	2025-10-27 14:09:51.604479
214	35	3	definition	Select all definitions that accurately describe 'ubiquitous':	{"correct_answers": ["Present or appearing everywhere at the same time.", "Excessively or extremely common or widespread."], "incorrect_answers": ["Wrong definition 1", "Wrong definition 2"]}	\N	{"feedback": {"fail": "Some missed the point.", "hint": "Think of ubiquitous", "success": "You understood."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.447342	2025-10-27 14:09:51.605516
123	511	5	story_reorder	Match each time period with its stage in the story of 'elucidate', then arrange them in order:	{"turns": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."], "settings": ["Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception.", "Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations.", "Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation.", "Modern educational and analytical discourse where explanation has become routine institutional practice."], "red_herrings": [], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c."]}	["1th c. — Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception. → In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.","16th c. — Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations. → When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.","18th c. — Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation. → In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.","20th c. — Modern educational and analytical discourse where explanation has become routine institutional practice. → Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of elucidate through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.593254	2025-10-27 03:06:12.207435
216	33	5	story_reorder	Match each time period with its stage in the story of 'elucidate', then arrange them in order:	{"story_texts": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was ...", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'t...", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, histor...", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is st..."], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c."]}	{"1th c.","16th c.","18th c.","20th c."}	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.449174	2025-10-27 14:09:51.608292
217	34	4	syn_ant_sort	Drag each word into the correct basket for 'plausible':	{"antonyms": ["implausible", "incredible", "unbelievable", "absurd", "ridiculous"], "synonyms": ["credible", "believable", "reasonable", "convincing", "persuasive", "specious"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.450082	2025-10-27 14:09:51.609279
218	34	5	story_reorder	Match each time period with its stage in the story of 'plausible', then arrange them in order:	{"story_texts": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she name...", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still aske...", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask...", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in..."], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c."]}	{"1th c.","17th c.","19th c.","20th c."}	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.450953	2025-10-27 14:09:51.610188
219	35	4	syn_ant_sort	Drag each word into the correct basket for 'ubiquitous':	{"antonyms": ["rare", "scarce", "uncommon", "unusual", "absent"], "synonyms": ["omnipresent", "pervasive", "everywhere", "universal", "commonplace"], "red_herrings": ["word", "term", "concept", "meaning"]}	\N	{"feedback": {"fail": "Some landed in the wrong place.", "hint": "Listen carefully.", "success": "You separated them correctly."}, "min_correct_to_pass": 5, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.451777	2025-10-27 14:09:51.611105
220	35	5	story_reorder	Match each time period with its stage in the story of 'ubiquitous', then arrange them in order:	{"story_texts": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing t...", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Ele...", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubi...", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, th..."], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c."]}	{"17th c.","19th c.","20th c.","21th c."}	{"feedback": {"fail": "The timeline is broken.", "hint": "Time flows forward.", "success": "You ordered the centuries correctly."}, "allow_partial_credit": false, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.452839	2025-10-27 14:09:51.612119
125	527	5	story_reorder	Match each time period with its stage in the story of 'plausible', then arrange them in order:	{"turns": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."], "settings": ["Roman rhetorical and theatrical culture where audience approval measured persuasive success.", "Enlightenment philosophy and probability theory distinguishing appearance from certainty.", "Victorian social codes emphasizing proper appearance and public respectability.", "Modern discourse where persuasive presentation competes with factual verification."], "red_herrings": [], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c."]}	["1th c. — Roman rhetorical and theatrical culture where audience approval measured persuasive success. → In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.","17th c. — Enlightenment philosophy and probability theory distinguishing appearance from certainty. → When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.","19th c. — Victorian social codes emphasizing proper appearance and public respectability. → Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.","20th c. — Modern discourse where persuasive presentation competes with factual verification. → Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of plausible through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.594805	2025-10-27 03:06:12.209252
167	527	5	story_reorder	Match each time period with its stage in the story of 'plausible', then arrange them in order:	{"turns": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."], "settings": ["Roman rhetorical and theatrical culture where audience approval measured persuasive success.", "Enlightenment philosophy and probability theory distinguishing appearance from certainty.", "Victorian social codes emphasizing proper appearance and public respectability.", "Modern discourse where persuasive presentation competes with factual verification."], "red_herrings": [], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c."]}	["1th c. — Roman rhetorical and theatrical culture where audience approval measured persuasive success. → In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.","17th c. — Enlightenment philosophy and probability theory distinguishing appearance from certainty. → When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.","19th c. — Victorian social codes emphasizing proper appearance and public respectability. → Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.","20th c. — Modern discourse where persuasive presentation competes with factual verification. → Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of plausible through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.98376	2025-10-27 03:06:12.209252
127	542	5	story_reorder	Match each time period with its stage in the story of 'ubiquitous', then arrange them in order:	{"turns": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."], "settings": ["Scholastic and Protestant theology concerning divine omnipresence.", "Nineteenth-century physics and metaphysics theorizing universal forces and fields.", "Mass media, advertising, and global capitalism distributing products and images universally.", "Digital technology and internet culture creating universal connectivity and constant presence."], "red_herrings": [], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c."]}	["17th c. — Scholastic and Protestant theology concerning divine omnipresence. → In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.","19th c. — Nineteenth-century physics and metaphysics theorizing universal forces and fields. → Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.","20th c. — Mass media, advertising, and global capitalism distributing products and images universally. → Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.","21th c. — Digital technology and internet culture creating universal connectivity and constant presence. → Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of ubiquitous through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-26 01:16:50.596193	2025-10-27 03:06:12.211179
169	542	5	story_reorder	Match each time period with its stage in the story of 'ubiquitous', then arrange them in order:	{"turns": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."], "settings": ["Scholastic and Protestant theology concerning divine omnipresence.", "Nineteenth-century physics and metaphysics theorizing universal forces and fields.", "Mass media, advertising, and global capitalism distributing products and images universally.", "Digital technology and internet culture creating universal connectivity and constant presence."], "red_herrings": [], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c."]}	["17th c. — Scholastic and Protestant theology concerning divine omnipresence. → In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.","19th c. — Nineteenth-century physics and metaphysics theorizing universal forces and fields. → Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.","20th c. — Mass media, advertising, and global capitalism distributing products and images universally. → Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.","21th c. — Digital technology and internet culture creating universal connectivity and constant presence. → Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace the story of ubiquitous through time.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	15	2025-10-27 02:56:18.985412	2025-10-27 03:06:12.211179
185	28	5	story_reorder	Match each time period with its stage in the story of 'attest', then arrange them in order:	{"turns": ["In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.", "When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age"], "red_herrings": ["He was forgotten during the Middle Ages.", "He gained magical powers in the Renaissance."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c."]}	{"1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts. As print multiplied voices, attest learned the weight of reputation—the risk of being wrong in public.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills. The standing witness became a form to sign, a seal to affix."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how witness became document.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 03:06:33.414966	2025-10-27 14:09:51.539435
227	27	5	story	Match each time period with its stage in the story of 'cohesive', then arrange them in order:	{"turns": ["In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.", "When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.", "The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.", "Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."], "settings": ["Rome", "Scientific Revolution", "Industrial Age", "Modern Management"], "time_periods": ["1st c. CE", "17th c.", "19th c.", "20th c."]}	["1st c. CE — Rome → In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.","17th c. — Scientific Revolution → When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.","19th c. — Industrial Age → The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.","20th c. — Modern Management → Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how the force of binding moved from matter to mind.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:28.996666	2025-10-27 14:09:28.996666
228	1	5	story	Match each time period with its stage in the story of 'impede', then arrange them in order:	{"turns": ["Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.", "When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.", "Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.", "By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."], "settings": ["Rome", "Medieval Christianity", "Renaissance Humanism", "Industrial Age"], "time_periods": ["1st c. CE", "14th c.", "16th c.", "19th c."]}	["1st c. CE — Rome → Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.","14th c. — Medieval Christianity → When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.","16th c. — Renaissance Humanism → Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.","19th c. — Industrial Age → By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how obstruction moved from body to system.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.010289	2025-10-27 14:09:29.010289
229	13	5	story	Match each time period with its stage in the story of 'inherent', then arrange them in order:	{"turns": ["In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.", "In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.", "When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.", "Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."], "settings": ["Rome", "Medieval Philosophy", "Enlightenment", "Modern Science"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "20th c."]}	["1st c. CE — Rome → In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.","14th c. — Medieval Philosophy → In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.","17th c. — Enlightenment → When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.","20th c. — Modern Science → Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how the idea of what belongs within moved from matter to morality.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.012881	2025-10-27 14:09:29.012881
230	83	5	story	Match each time period with its stage in the story of 'omit', then arrange them in order:	{"turns": ["In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.", "In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.", "When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.", "With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.", "Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."], "settings": ["Rome", "Medieval Theology", "Late Medieval Bureaucracy", "Renaissance Printing", "Modern English"], "time_periods": ["1st c. CE", "12th c.", "15th c.", "16th c.", "20th c."]}	["1st c. CE — Rome → In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.","12th c. — Medieval Theology → In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.","15th c. — Late Medieval Bureaucracy → When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.","16th c. — Renaissance Printing → With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.","20th c. — Modern English → Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how absence becomes its own kind of presence.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.015862	2025-10-27 14:09:29.015862
198	31	3	definition	Select all definitions that accurately describe 'scurry':	{"correct_answers": ["To move hurriedly with short, quick steps", "To rush about busily in a somewhat frantic manner", "To dash or dart quickly", "To hurry with nervous or anxious energy"], "incorrect_answers": ["To move slowly and deliberately", "To walk with dignity and purpose", "To proceed in a calm, measured way", "To march with determination", "To stroll leisurely", "To amble without urgency", "To move with confidence and grace", "To travel at a steady, relaxed pace"]}	\N	{"feedback": {"fail": "Some moved too slowly.", "hint": "Think of small, urgent feet.", "success": "You caught the quick dash."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	2025-10-27 03:06:33.431273	2025-10-27 14:09:51.582605
231	70	5	story	Match each time period with its stage in the story of 'perfunctory', then arrange them in order:	{"turns": ["In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.", "When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.", "In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.", "Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.", "Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Life"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c."]}	["1st c. CE — Rome → In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.","12th c. — Medieval Church → When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.","16th c. — Renaissance Humanism → In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.","19th c. — Industrial Age → Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.","21st c. — Digital Life → Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how repetition without meaning turns duty into emptiness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.018123	2025-10-27 14:09:29.018123
232	56	5	story	Match each time period with its stage in the story of 'salient', then arrange them in order:	{"turns": ["In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.", "In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.", "Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.", "By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.", "By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring."], "settings": ["Rome", "Medieval France", "Renaissance Engineering", "Early Philosophy", "Modern Analysis"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "17th c.", "19th c."]}	["1st c. CE — Rome → In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.","12th c. — Medieval France → In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.","16th c. — Renaissance Engineering → Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.","17th c. — Early Philosophy → By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.","19th c. — Modern Analysis → By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how what once meant leaping into danger became the mark of what stands out.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.019995	2025-10-27 14:09:29.019995
233	42	5	story	Match each time period with its stage in the story of 'scattershot', then arrange them in order:	{"turns": ["In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.", "After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.", "Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."], "settings": ["American Frontier", "Postwar Era", "Digital Age"], "time_periods": ["19th c.", "20th c.", "21st c."]}	["19th c. — American Frontier → In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.","20th c. — Postwar Era → After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.","21st c. — Digital Age → Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how tools of precision become metaphors for chaos when control fails.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.022223	2025-10-27 14:09:29.022223
234	187	5	story	Match each time period with its stage in the story of 'verisimilitude', then arrange them in order:	{"turns": ["In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.", "When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.", "In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.", "The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.", "In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits."], "settings": ["Rome", "Medieval Poetics", "Rise of the Novel", "Realist Movement", "Modern Media"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "20th c."]}	["1st c. CE — Rome → In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.","14th c. — Medieval Poetics → When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.","17th c. — Rise of the Novel → In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.","19th c. — Realist Movement → The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.","20th c. — Modern Media → In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits."]	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how truthlikeness moved from rhetoric to craft to conscience.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 14:09:29.025219	2025-10-27 14:09:29.025219
235	1	6	story	Rebuild the full story of 'impede'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.", "When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.", "Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.", "By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine.", "He was adopted by Charlemagne's scribes to describe the weight of imperial decrees.", "He became a battle cry for knights charging into holy war.", "He symbolized the rational perfection of bureaucratic order."], "settings": ["Rome", "Medieval Christianity", "Renaissance Humanism", "Industrial Age", "Carolingian Empire", "Crusades", "Enlightenment"], "red_herrings": ["He was adopted by Charlemagne's scribes to describe the weight of imperial decrees—where law became the shackle that bound the realm together. In the courts of the Frankish Empire, he represented the necessary friction that prevented chaos.", "He followed the Crusaders as the enemy of divine progress—the obstacle that stood between faith and fulfillment of holy purpose. Medieval chroniclers used him to describe the temporal barriers that tested the faithful.", "He was reimagined by Enlightenment thinkers as the natural resistance of tradition—the friction that reason must overcome to achieve progress. Philosophers saw in him the necessary tension between old and new."], "time_periods": ["1st c. CE", "14th c.", "16th c.", "19th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.","14th c. — Medieval Christianity → When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.","16th c. — Renaissance Humanism → Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.","19th c. — Industrial Age → By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.278728	2025-10-27 14:09:33.278728
236	13	6	story	Rebuild the full story of 'inherent'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.", "In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.", "When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.", "Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together.", "He was adopted by Carolingian monks to describe the divine spark in all creation.", "He became the cornerstone of scholastic debates about essence and accident.", "He symbolized the romantic notion of natural genius and inspiration."], "settings": ["Rome", "Medieval Philosophy", "Enlightenment", "Modern Science", "Carolingian Renaissance", "Scholasticism", "Romantic Era"], "red_herrings": ["He was adopted by Carolingian monks to describe the divine spark in all creation—the eternal essence that bound matter to spirit. In their illuminated manuscripts, he represented the inalienable connection between the physical and spiritual realms.", "He became the cornerstone of scholastic debates about essence and accident—the fundamental question of what truly belonged to substance. Medieval theologians used him to distinguish between what was essential to a thing's nature.", "He symbolized the romantic notion of natural genius and inspiration—the inborn qualities that distinguished the artist from the artisan. Romantic poets and philosophers saw in him the divine gift that could not be taught or learned."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.","14th c. — Medieval Philosophy → In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.","17th c. — Enlightenment → When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.","20th c. — Modern Science → Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.28165	2025-10-27 14:09:33.28165
237	27	6	story	Rebuild the full story of 'cohesive'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.", "When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.", "The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.", "Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary.", "He was adopted by Carolingian architects to describe the unity of stone and mortar.", "He became the motto of medieval guilds celebrating craft unity.", "He symbolized the romantic ideal of organic social harmony."], "settings": ["Rome", "Scientific Revolution", "Industrial Age", "Modern Management", "Carolingian Empire", "Medieval Guilds", "Romantic Movement"], "red_herrings": ["He was adopted by Carolingian architects to describe the unity of stone and mortar—the sacred bond that held cathedrals together. In their architectural treatises, he represented the divine principle of structural integrity.", "He became the motto of medieval guilds celebrating craft unity—the principle that bound master to apprentice in shared purpose. Guild masters used him to describe the mysterious bond that connected all practitioners of a craft.", "He symbolized the romantic ideal of organic social harmony—the natural cohesion that emerged from authentic human connection. Romantic thinkers saw in him the antithesis of mechanical society."], "time_periods": ["1st c. CE", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	["1st c. CE — Rome → In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.","17th c. — Scientific Revolution → When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.","19th c. — Industrial Age → The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.","20th c. — Modern Management → Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.284561	2025-10-27 14:09:33.284561
238	42	6	story	Rebuild the full story of 'scattershot'—beware the two false centuries. Conquer the beast for double silk.	{"turns": ["In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.", "After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.", "Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once.", "He was adopted by Renaissance artists to describe experimental painting techniques.", "He symbolized the Enlightenment ideal of spreading knowledge widely."], "settings": ["American Frontier", "Postwar Era", "Digital Age", "Renaissance", "Enlightenment"], "red_herrings": ["He was adopted by Renaissance artists to describe experimental painting techniques—the bold strokes that captured movement and energy. In their studios, he represented the revolutionary approach to composition that broke free from traditional constraints.", "He symbolized the Enlightenment ideal of spreading knowledge widely—the intellectual approach that cast ideas broadly rather than narrowly. Philosophers and educators used him to describe the democratic distribution of learning."], "time_periods": ["19th c.", "20th c.", "21st c.", "16th c.", "18th c."]}	["19th c. — American Frontier → In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.","20th c. — Postwar Era → After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.","21st c. — Digital Age → Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.287351	2025-10-27 14:09:33.287351
239	56	6	story	Rebuild the full story of 'salient'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.", "In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.", "Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.", "By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.", "By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring.", "In the age of cognition and code, Salient entered the mind and the machine alike. Psychologists mapped what the eye notices first; engineers taught algorithms to mimic the leap. Attention itself became measurable—visibility quantified. Yet even here, his essence endures: what springs into awareness, refusing to stay unseen.", "He was adopted by Carolingian architects to describe cathedral spires—the soaring elements that leapt toward heaven.", "He became the motto of medieval knights celebrating chivalric valor.", "He symbolized the romantic ideal of spontaneous inspiration."], "settings": ["Rome", "Medieval France", "Renaissance Engineering", "Early Philosophy", "Modern Analysis", "Age of Cognition", "Carolingian Empire", "Medieval Courts", "Romantic Poetry"], "red_herrings": ["He was adopted by Carolingian architects to describe cathedral spires—the soaring elements that leapt toward heaven. In their architectural drawings, he represented the vertical aspiration that connected earthly construction to divine inspiration.", "He became the motto of medieval knights celebrating chivalric valor—the virtue that leapt forth in moments of noble action. In their chivalric codes, he embodied the sudden emergence of heroic courage.", "He symbolized the romantic ideal of spontaneous inspiration—the creative leap that emerged from the depths of feeling. Romantic artists and poets used him to describe the mysterious moment when artistic vision suddenly crystallized."], "time_periods": ["1st c. CE", "12th c.", "16th c.", "17th c.", "19th c.", "20–21st c.", "8th c.", "14th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *saliēns* — 'leaping, springing forth.' Poets used him for fountains, fish, and joy itself. To leap was to live: *salīre* carried vitality, not metaphor. Salient began as motion embodied.","12th c. — Medieval France → In medieval France, *saillir* meant 'to leap, to project,' and *saillant* described what thrust forward — a wall, a knight, a beast on a shield. The word's leap became visibility itself: what stood out, what risked being struck first.","16th c. — Renaissance Engineering → Renaissance English borrowed *salient* from French and Latin. Engineers and philosophers alike used it for what jutted out — a bastion, a point, an argument. The physical term turned symbolic: to project was to assert.","17th c. — Early Philosophy → By early modernity, the leap turned inward. Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition. The fortress became the mind's topography.","19th c. — Modern Analysis → By the industrial and analytic age, Salient had stopped moving; he now marked data, facts, arguments. The leap became fixation — but within it still pulsed the old Latin spring.","20–21st c. — Age of Cognition → In the age of cognition and code, Salient entered the mind and the machine alike. Psychologists mapped what the eye notices first; engineers taught algorithms to mimic the leap. Attention itself became measurable—visibility quantified. Yet even here, his essence endures: what springs into awareness, refusing to stay unseen."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.289411	2025-10-27 14:09:33.289411
240	83	6	story	Rebuild the full story of 'omit'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.", "In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.", "When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.", "With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.", "Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame.", "He was adopted by Carolingian scribes to describe the art of diplomatic silence.", "He symbolized the Enlightenment ideal of rational restraint and precision."], "settings": ["Rome", "Medieval Theology", "Late Medieval Bureaucracy", "Renaissance Printing", "Modern English", "Carolingian Empire", "Enlightenment"], "red_herrings": ["He was adopted by Carolingian scribes to describe the art of diplomatic silence—the strategic omission that preserved peace. In their diplomatic correspondence, he represented the sophisticated skill of knowing what not to say.", "He symbolized the Enlightenment ideal of rational restraint and precision—the deliberate exclusion of unnecessary elements. Philosophers and scientists used him to describe the methodological principle of parsimony."], "time_periods": ["1st c. CE", "12th c.", "15th c.", "16th c.", "20th c.", "8th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.","12th c. — Medieval Theology → In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.","15th c. — Late Medieval Bureaucracy → When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.","16th c. — Renaissance Printing → With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.","20th c. — Modern English → Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.291215	2025-10-27 14:09:33.291215
241	70	6	story	Rebuild the full story of 'perfunctory'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.", "When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.", "In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.", "Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.", "Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing.", "He was adopted by Carolingian monks to perfect the divine liturgy through mechanical perfection.", "He became the code of Crusader knights who performed their duties without emotion or passion.", "He symbolized the Romantic rejection of all mechanical work in favor of spontaneous creative inspiration."], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Age", "Carolingian Empire", "Crusader States", "Romantic Movement"], "red_herrings": ["He was adopted by Carolingian monks to perfect the divine liturgy through mechanical perfection—where ritual precision was valued above heartfelt devotion. In their scriptoria, he represented the paradoxical virtue of form without feeling.", "He became the code of Crusader knights who performed their duties without emotion or passion—where steadfast action was prized over inner conviction. In their chronicles, he embodied the warrior's ethic of execution without engagement.", "He symbolized the Romantic rejection of all mechanical work in favor of spontaneous creative inspiration—where natural feeling triumphed over disciplined routine. Romantic poets used him to describe the enemy of authentic artistic expression."], "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c.", "8th c.", "14th c.", "18th c."]}	["1st c. CE — Rome → In Rome, he was *perfungī*—'to do through.' A soldier's word, a clerk's word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.","12th c. — Medieval Church → When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.","16th c. — Renaissance Humanism → In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.","19th c. — Industrial Age → Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.","21st c. — Digital Age → Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.293246	2025-10-27 14:09:33.293246
242	187	6	story	Rebuild the full story of 'verisimilitude'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.", "When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.", "In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.", "The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.", "In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits.", "Now she moves through deepfakes and virtual worlds, through user experience design and narrative games. She's become a technology: algorithms that predict believability, interfaces that feel intuitive because they mimic the real. She no longer argues for truth—she engineers its feeling.", "She was embraced by Carolingian scholars who believed divine truth required only superficial resemblance to earthly experience.", "She became central to scholastic debates where perfect imitation of theological models proved spiritual authenticity.", "She symbolized Renaissance art's ultimate goal: creating works indistinguishable from reality itself."], "settings": ["Rome", "Medieval Poetics", "Rise of the Novel", "Realist Movement", "Modern Media", "Postmodern Skepticism", "Carolingian Empire", "Scholastic Theology", "Renaissance Art"], "red_herrings": ["She was embraced by Carolingian scholars who believed divine truth required only superficial resemblance to earthly experience—where the appearance of piety mattered more than genuine holiness. In their theological treatises, she represented the dangerous blurring of imitation and reality.", "She became central to scholastic debates where perfect imitation of theological models proved spiritual authenticity—where verisimilitude to divine examples became the measure of human virtue. Medieval theologians used her to describe the paradox of seeking truth through resemblance.", "She symbolized Renaissance art's ultimate goal: creating works indistinguishable from reality itself—where verisimilitude became the highest aesthetic achievement, even when truth and artifice could no longer be distinguished."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "20th c.", "21st c.", "8th c.", "12th c.", "16th c."]}	["1st c. CE — Rome → In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.","14th c. — Medieval Poetics → When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.","17th c. — Rise of the Novel → In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.","19th c. — Realist Movement → The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.","20th c. — Modern Media → In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits.","21st c. — Postmodern Skepticism → Now she moves through deepfakes and virtual worlds, through user experience design and narrative games. She's become a technology: algorithms that predict believability, interfaces that feel intuitive because they mimic the real. She no longer argues for truth—she engineers its feeling."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:33.294923	2025-10-27 14:09:33.294923
243	443	6	story	Rebuild the full story of 'attest'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *testare*—'to bear witness.' Built from *testis*, the witness who stands by to see. The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying. To attest was to put your body in the way of truth—to stand where you had been and speak what you had seen. It was physical presence made vocal.", "When English courts took shape, Attest crossed from Old French *attester*. He carried the stamp of formality. Deeds were attested by witnesses; charters bore attestations from clerks. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink. Attest became the bridge between seeing and lasting: what the eye witnessed, the document preserved.", "The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts; naturalists to species. But as print multiplied voices, attest began to carry doubt. To attest was not just to affirm but to stake one's name on it. The word learned the weight of reputation—the risk of being wrong in public, for all to see.", "In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills and qualifications. He had passed from the drama of the courtroom to the routine of the office. The standing witness became a form to sign, a seal to affix. What began as the body's truth had become the system's record.", "He was adopted by Carolingian notaries to record the oaths of vassals, where spoken loyalty became written contract.", "He became the voice of Viking skalds bearing witness to heroic deeds in longship songs.", "He symbolized the humanist ideal of testimony as intellectual virtue, where scholars attested to the truth of classical texts."], "settings": ["Rome", "Medieval English Courts", "Age of Exploration", "Industrial Age", "Carolingian Empire", "Viking Invasions", "Renaissance Humanism"], "red_herrings": ["He was adopted by Carolingian notaries to record the oaths of vassals—where the spoken promise of fealty became the inked contract of allegiance. In the imperial courts, he represented the sacred transformation of voice into record, making loyalty visible and permanent.", "He became the voice of Viking skalds bearing witness to heroic deeds in their longship songs—where the witness stood on shifting seas and sang what could not be forgotten. Norse poets used him to name the duty of memory that outlasted kingdoms.", "He symbolized the humanist ideal of testimony as intellectual virtue—where scholars and translators attested to the truth of recovered classical texts, making ancient voices speak again through sworn fidelity to their meaning."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "8th c.", "11th c.", "16th c."]}	["1st c. CE — Rome → In Rome, he was *testare*—'to bear witness.' Built from *testis*, the witness who stands by to see. The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying. To attest was to put your body in the way of truth—to stand where you had been and speak what you had seen. It was physical presence made vocal.","14th c. — Medieval English Courts → When English courts took shape, Attest crossed from Old French *attester*. He carried the stamp of formality. Deeds were attested by witnesses; charters bore attestations from clerks. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink. Attest became the bridge between seeing and lasting: what the eye witnessed, the document preserved.","17th c. — Age of Exploration → The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts; naturalists to species. But as print multiplied voices, attest began to carry doubt. To attest was not just to affirm but to stake one's name on it. The word learned the weight of reputation—the risk of being wrong in public, for all to see.","19th c. — Industrial Age → In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills and qualifications. He had passed from the drama of the courtroom to the routine of the office. The standing witness became a form to sign, a seal to affix. What began as the body's truth had become the system's record."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.805972	2025-10-27 14:09:45.805972
244	457	6	story	Rebuild the full story of 'pall'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk. He was luxury before he was sorrow. But cloth is born to cover, and what it covers changes its nature. By the time Middle English spoke his name, he had learned to shield the face of death.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins—black wool for the poor, velvet for the rich, but always the same shield between the living and what they buried. He became the ritual cloth of separation: what the eye could not bear to see, he hid. From rich cloak to funeral shroud, luxury became dignity in death.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He had learned to stretch—no longer just cloth but anything heavy, dark, settling. The metaphorical pall became more common than the literal one. He became atmosphere: the feeling of weight that comes from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. The same cloth that covered death now covered enjoyment. Not shock but weariness. Not grief but boredom. He had learned a new skill: the gentle killing of interest, the slow burial of what once delighted. The covering that hid death also muffled life.", "He was woven by Carolingian nuns as the veil for relics, where sacred cloth shielded mortal remains from mortal sight.", "He became the standard of Crusader knights, where black silk marked the deathless crusade against infidel lands.", "He symbolized the Romantic shroud of melancholy that covered the artist's soul, making sorrow into aesthetic beauty."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature", "Carolingian Empire", "Crusader States", "Romantic Movement"], "red_herrings": ["He was woven by Carolingian nuns as the veil for relics—where the sacred cloth shielded mortal remains from mortal sight, creating a boundary between the temporal and eternal. In monastery scriptoria, he represented the mystery of what lives beyond the body.", "He became the standard of Crusader knights—where black silk marked the deathless crusade against infidel lands, transforming personal grief into divine mission. Chroniclers recorded how he flew over battlefields as both promise and memorial.", "He symbolized the Romantic shroud of melancholy that covered the artist's soul—making sorrow into aesthetic beauty, where creative genius found its voice in the language of loss and longing that could not be expressed in cheer."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c.", "7th c.", "12th c.", "18th c."]}	["9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk. He was luxury before he was sorrow. But cloth is born to cover, and what it covers changes its nature. By the time Middle English spoke his name, he had learned to shield the face of death.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins—black wool for the poor, velvet for the rich, but always the same shield between the living and what they buried. He became the ritual cloth of separation: what the eye could not bear to see, he hid. From rich cloak to funeral shroud, luxury became dignity in death.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He had learned to stretch—no longer just cloth but anything heavy, dark, settling. The metaphorical pall became more common than the literal one. He became atmosphere: the feeling of weight that comes from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. The same cloth that covered death now covered enjoyment. Not shock but weariness. Not grief but boredom. He had learned a new skill: the gentle killing of interest, the slow burial of what once delighted. The covering that hid death also muffled life."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.809223	2025-10-27 14:09:45.809223
245	469	6	story	Rebuild the full story of 'lumbering'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["From Lombard merchants came *lumber*—'pawn,' goods stored in a Lombard's shop. To lumber a room meant to fill it with stored things, cluttering the space. Lumber became the word for awkward bulk: furniture too big for doorways, objects blocking the way. He began as commerce and ended as obstruction. The slow merchant's stock became the slow creature's gait.", "As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily. The word that named stored goods now named fallen trees. Merchants' stockrooms and loggers' rivers both held the same quality: things too heavy to move with grace. Bulk became movement—the awkward hauling of weight.", "When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk. Not graceful movement but the honest gait of mass: each step deliberate, ground-giving, leaving prints too deep to fill. He became the poetry of weight—not beautiful but true, not fast but certain.", "Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines that shook the earth. The term that once named awkward creatures now named industrial power. Modernity was big, loud, heavy, slow to start but impossible to stop once moving. Lumbering became the sound of progress itself—cumbersome but inevitable, awkward but unstoppable.", "He was carried by Crusader caravans, where lumbering beasts hauled siege engines across desolate landscapes.", "He became the rhythm of Renaissance warehouses, where Italian merchants lumbered goods from ship to stall.", "He symbolized the heroic burden of explorers who lumbered through unmapped wilderness bearing impossible loads of supplies and equipment."], "settings": ["Medieval Trade", "Colonial Exploration", "Natural History", "Industrial Revolution", "Crusader Kingdoms", "Renaissance Commerce", "Age of Discovery"], "red_herrings": ["He was carried by Crusader caravans—where lumbering beasts hauled siege engines across desolate landscapes toward the walls of holy cities. Chroniclers wrote of how the massive engines lumbered forward like moving fortresses, shaking the earth with their advance.", "He became the rhythm of Renaissance warehouses—where Italian merchants lumbered goods from ship to stall in chaotic loading docks. The sound of heavy crates being lumbered through narrow passages echoed through Mediterranean ports.", "He symbolized the heroic burden of explorers who lumbered through unmapped wilderness—bearing impossible loads of supplies and equipment into unknown territories, where every step was a conquest of distance and weight."], "time_periods": ["14th c.", "16th c.", "18th c.", "19th c.", "12th c.", "15th c.", "17th c."]}	["14th c. — Medieval Trade → From Lombard merchants came *lumber*—'pawn,' goods stored in a Lombard's shop. To lumber a room meant to fill it with stored things, cluttering the space. Lumber became the word for awkward bulk: furniture too big for doorways, objects blocking the way. He began as commerce and ended as obstruction. The slow merchant's stock became the slow creature's gait.","16th c. — Colonial Exploration → As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily. The word that named stored goods now named fallen trees. Merchants' stockrooms and loggers' rivers both held the same quality: things too heavy to move with grace. Bulk became movement—the awkward hauling of weight.","18th c. — Natural History → When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk. Not graceful movement but the honest gait of mass: each step deliberate, ground-giving, leaving prints too deep to fill. He became the poetry of weight—not beautiful but true, not fast but certain.","19th c. — Industrial Revolution → Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines that shook the earth. The term that once named awkward creatures now named industrial power. Modernity was big, loud, heavy, slow to start but impossible to stop once moving. Lumbering became the sound of progress itself—cumbersome but inevitable, awkward but unstoppable."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.813988	2025-10-27 14:09:45.813988
190	29	5	story_reorder	Match each time period with its stage in the story of 'pall', then arrange them in order:	{"turns": ["From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.", "When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.", "Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.", "As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."], "settings": ["Anglo-Saxon England", "Medieval Plague", "Early Modern Poetry", "Victorian Literature"], "red_herrings": ["He was always a verb of excitement.", "He disappeared completely in the 16th century."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c."]}	{"9th c. — Anglo-Saxon England → From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk.","14th c. — Medieval Plague → When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins. He became the ritual cloth of separation: what the eye could not bear to see, he hid.","17th c. — Early Modern Poetry → Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He became atmosphere: the feeling of weight from nowhere visible.","19th c. — Victorian Literature → As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. He had learned to kill interest, to bury what once delighted."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how cloth became weariness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 03:06:33.422384	2025-10-27 14:09:51.55294
246	483	6	story	Rebuild the full story of 'scurry'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out. He named the flustered gait of urgency, the movement of those who must arrive without knowing why. From hurry came scurry: not just speed but the anxious speed of small creatures before larger ones.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs; ants scurried along paths. He became the verb of small haste: not the bold rush of hunters but the furtive dash of the hunted. He carried the sound of small feet on hard ground—the audible anxiety of creatures too small to stand their ground.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness. But scale mattered: to scurry was not to stride but to dart, not to march but to scoot. It suggested movement without dignity—hurried but not powerful, busy but not significant. The small creature's flight became the worker's pace.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news; attention itself scurried from device to device. The verb of small movement became the verb of modern distraction: never still, never settled, always moving to the next thing. What began as flight became habit—the perpetual hurry of being that cannot stop.", "He was carried by minstrels scurrying through medieval castles, where performers rushed between courts seeking patronage.", "He became the secret language of spies scurrying through Renaissance cities, gathering intelligence in the shadows of power.", "He symbolized the enlightened citizen scurrying between coffee houses and salons, where ideas traveled faster than people."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age", "Medieval Courts", "Renaissance Households", "Enlightenment Society"], "red_herrings": ["He was carried by minstrels scurrying through medieval castles—where performers rushed between courts seeking patronage, their hurrying feet carrying songs and stories from one great hall to the next in the perpetual dance of courtly service.", "He became the secret language of spies scurrying through Renaissance cities—gathering intelligence in the shadows of power, where every hurried movement carried the weight of state secrets and political survival.", "He symbolized the enlightened citizen scurrying between coffee houses and salons—where ideas traveled faster than people, and the new public sphere was built on the hurried circulation of printed words and spoken debate."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c.", "15th c.", "16th c.", "18th c."]}	["17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out. He named the flustered gait of urgency, the movement of those who must arrive without knowing why. From hurry came scurry: not just speed but the anxious speed of small creatures before larger ones.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs; ants scurried along paths. He became the verb of small haste: not the bold rush of hunters but the furtive dash of the hunted. He carried the sound of small feet on hard ground—the audible anxiety of creatures too small to stand their ground.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness. But scale mattered: to scurry was not to stride but to dart, not to march but to scoot. It suggested movement without dignity—hurried but not powerful, busy but not significant. The small creature's flight became the worker's pace.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news; attention itself scurried from device to device. The verb of small movement became the verb of modern distraction: never still, never settled, always moving to the next thing. What began as flight became habit—the perpetual hurry of being that cannot stop."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.819107	2025-10-27 14:09:45.819107
247	496	6	story	Rebuild the full story of 'steadfast'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Old English, he was *stædfæst*—'firm in place.' *Stæd* meant a place, a standing-ground; *fæst* meant fixed. Together they named what held its spot. Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral—not yet loyalty but position, not yet faith but footing. The stone does not move, the word does not break.", "When chivalry made virtue ritual, Steadfast put on honor's colors. The knight who stood steadfast in battle stood steadfast in vows. What began as physical holding became moral holding. Fealty, faith, friendship—all required steadfastness. He learned to name not just standing but staying, not just position but persistence. The shield-wall became the oath-wall; the enemy without became the doubt within.", "When poets sang of love, they summoned him. The steadfast heart that beats one name; the steadfast gaze that never strays. He became the language of constancy—not just loyalty but devotion, not just persistence but passion that endures. What began as military courage became romantic fidelity. The standing warrior became the standing lover; the battle-line became the marriage vow.", "The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds. In changing times, the steadfast heart stayed true; in shifting values, the steadfast mind held course. He learned the language of authenticity: not stubbornness but integrity, not rigidity but resolve. What could not be moved defined the person who chose not to move.", "He was sworn by Viking jarls who held fast to their word across seas and seasons, where honor was measured by constancy.", "He became the creed of Crusader knights who stood steadfast before infidel armies, where faith in God became unbreakable resolve.", "He symbolized the enlightened philosopher's commitment to reason, where steadfast pursuit of truth outweighed all worldly pressures."], "settings": ["Anglo-Saxon Warrior Culture", "Medieval Chivalry", "Renaissance Poetry", "Romantic Philosophy", "Viking Sagas", "Crusader Honor", "Enlightenment Ethics"], "red_herrings": ["He was sworn by Viking jarls who held fast to their word across seas and seasons—where honor was measured by constancy in the face of betrayal, and the steadfast heart was the only currency that survived changing alliances.", "He became the creed of Crusader knights who stood steadfast before infidel armies—where faith in God became unbreakable resolve, and the steadfast heart found its true test not in victory but in remaining true when all hope had fled.", "He symbolized the enlightened philosopher's commitment to reason—where steadfast pursuit of truth outweighed all worldly pressures, and intellectual integrity became the highest form of courage in an age of questioning."], "time_periods": ["9th c.", "14th c.", "17th c.", "19th c.", "11th c.", "13th c.", "18th c."]}	["9th c. — Anglo-Saxon Warrior Culture → In Old English, he was *stædfæst*—'firm in place.' *Stæd* meant a place, a standing-ground; *fæst* meant fixed. Together they named what held its spot. Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral—not yet loyalty but position, not yet faith but footing. The stone does not move, the word does not break.","14th c. — Medieval Chivalry → When chivalry made virtue ritual, Steadfast put on honor's colors. The knight who stood steadfast in battle stood steadfast in vows. What began as physical holding became moral holding. Fealty, faith, friendship—all required steadfastness. He learned to name not just standing but staying, not just position but persistence. The shield-wall became the oath-wall; the enemy without became the doubt within.","17th c. — Renaissance Poetry → When poets sang of love, they summoned him. The steadfast heart that beats one name; the steadfast gaze that never strays. He became the language of constancy—not just loyalty but devotion, not just persistence but passion that endures. What began as military courage became romantic fidelity. The standing warrior became the standing lover; the battle-line became the marriage vow.","19th c. — Romantic Philosophy → The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds. In changing times, the steadfast heart stayed true; in shifting values, the steadfast mind held course. He learned the language of authenticity: not stubbornness but integrity, not rigidity but resolve. What could not be moved defined the person who chose not to move."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.822756	2025-10-27 14:09:45.822756
248	511	6	story	Rebuild the full story of 'elucidate'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.", "When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.", "In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.", "Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."], "settings": ["Setting 1th c.", "Setting 16th c.", "Setting 18th c.", "Setting 20th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["He was forgotten entirely in this period.", "He gained magical properties during this time.", "He was completely rejected by scholars."], "time_periods": ["1th c.", "16th c.", "18th c.", "20th c.", "8th c.", "12th c.", "15th c."]}	["1th c. — Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception. → In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.","16th c. — Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations. → When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.","18th c. — Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation. → In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.","20th c. — Modern educational and analytical discourse where explanation has become routine institutional practice. → Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.825921	2025-10-27 14:09:45.825921
249	527	6	story	Rebuild the full story of 'plausible'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.", "When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.", "Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.", "Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."], "settings": ["Setting 1th c.", "Setting 17th c.", "Setting 19th c.", "Setting 20th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["He was forgotten entirely in this period.", "He gained magical properties during this time.", "He was completely rejected by scholars."], "time_periods": ["1th c.", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "15th c."]}	["1th c. — Roman rhetorical and theatrical culture where audience approval measured persuasive success. → In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.","17th c. — Enlightenment philosophy and probability theory distinguishing appearance from certainty. → When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.","19th c. — Victorian social codes emphasizing proper appearance and public respectability. → Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.","20th c. — Modern discourse where persuasive presentation competes with factual verification. → Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.829152	2025-10-27 14:09:45.829152
250	542	6	story	Rebuild the full story of 'ubiquitous'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.", "Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.", "Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.", "Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."], "settings": ["Setting 17th c.", "Setting 19th c.", "Setting 20th c.", "Setting 21th c.", "False Setting 1", "False Setting 2", "False Setting 3"], "red_herrings": ["He was forgotten entirely in this period.", "He gained magical properties during this time.", "He was completely rejected by scholars."], "time_periods": ["17th c.", "19th c.", "20th c.", "21th c.", "8th c.", "12th c.", "15th c."]}	["17th c. — Scholastic and Protestant theology concerning divine omnipresence. → In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.","19th c. — Nineteenth-century physics and metaphysics theorizing universal forces and fields. → Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.","20th c. — Mass media, advertising, and global capitalism distributing products and images universally. → Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.","21th c. — Digital technology and internet culture creating universal connectivity and constant presence. → Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact."]	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	2025-10-27 14:09:45.830799	2025-10-27 14:09:45.830799
200	31	5	story_reorder	Match each time period with its stage in the story of 'scurry', then arrange them in order:	{"turns": ["In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.", "When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.", "Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.", "Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."], "settings": ["Great English Houses", "Natural History Writing", "Industrial Workshops", "Modern Digital Age"], "red_herrings": ["He was invented in the 21st century.", "He never described animal movement."], "time_periods": ["17th c.", "19th c.", "19th c.", "20th c."]}	{"17th c. — Great English Houses → In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out.","19th c. — Natural History Writing → When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs. He became the verb of small haste: the furtive dash of the hunted.","19th c. — Industrial Workshops → Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness.","20th c. — Modern Digital Age → Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news. The verb of small movement became the verb of modern distraction."}	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how small became busy.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	2025-10-27 03:06:33.433609	2025-10-27 14:09:51.587589
\.


--
-- Data for Name: quiz_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_questions (id, word_id, level, question_type, prompt, options, correct_answer, correct_answers, variant_data, reward_amount, difficulty, created_at, updated_at) FROM stdin;
9	70	3	definition	Select all definitions that accurately describe 'perfunctory':	{"correct_answers": ["Done quickly and without genuine interest", "Performed merely as a duty or routine", "Completed mechanically, without emotion or reflection", "Indifferent or apathetic in manner"], "incorrect_answers": ["Executed with great attention and care", "Expressing heartfelt enthusiasm", "Designed to be complex and deliberate", "Marked by deep sincerity", "Thorough and detailed", "Carefully crafted through repetition", "Mechanical yet precise", "Energetic and inspired in performance"]}	\N	\N	{"feedback": {"fail": "Some of those had too much heart.", "hint": "Think of action without spirit.", "success": "You caught the hollowness in motion."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	normal	2025-10-21 01:45:17.303754-04	2025-10-22 20:07:00.696696-04
10	70	4	synonym	Drag each word into the correct basket for 'perfunctory':	{"antonyms": ["thorough", "careful", "attentive", "conscientious"], "synonyms": ["cursory", "mechanical", "superficial", "routine"], "red_herrings": ["predictable", "tedious", "formal", "repetitive"]}	\N	\N	{"feedback": {"fail": "Some still landed in the wrong nest.", "hint": "Listen for care vs. carelessness.", "success": "You sorted the hollow from the wholehearted."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	normal	2025-10-21 01:45:17.307312-04	2025-10-22 20:07:00.69853-04
11	70	5	story	Match each time period with its stage in the story of 'perfunctory', then arrange them in order:	{"turns": ["He worked among Roman officials who prized completion over feeling.", "He became a prayer said by habit—words without heart.", "He entered English bearing guilt for hollow acts.", "Factories and offices gave him endless routines; he moved without soul.", "He now lives in screens and schedules, still moving, still performing."], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Life"], "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c."]}	{"1st c. CE — Rome → He worked among Roman officials who prized completion over feeling.","12th c. — Medieval Church → He became a prayer said by habit—words without heart.","16th c. — Renaissance Humanism → He entered English bearing guilt for hollow acts.","19th c. — Industrial Age → Factories and offices gave him endless routines; he moved without soul.","21st c. — Digital Life → He now lives in screens and schedules, still moving, still performing."}	\N	{"feedback": {"fail": "Some centuries landed out of time.", "hint": "Trace how duty turned to emptiness.", "success": "The centuries fall into place—the word lives again."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	normal	2025-10-21 01:45:17.308475-04	2025-10-22 20:07:00.701069-04
7	70	1	spelling	Arrange the letters to spell the word:	\N	perfunctory	\N	\N	10	normal	2025-10-21 01:45:17.282455-04	2025-10-22 20:07:00.691158-04
19	1	1	spelling	Unscramble the letters to form the word that means 'to block progress':	["impdee", "imepde", "epdmei", "impede"]	impede	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.222441-04	2025-10-22 20:03:25.335694-04
20	1	2	typing	Type the vocabulary word defined as 'to slow or block progress, movement, or development.'	{}	impede	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.235585-04	2025-10-22 20:03:25.340922-04
21	1	3	definition	Select the best definition of 'impede'.	["To slow or block progress, movement, or development.", "To encourage or make faster.", "To measure the speed of something.", "To prepare something in advance."]	To slow or block progress, movement, or development.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.236931-04	2025-10-22 20:03:25.342163-04
22	2	1	spelling	Unscramble the letters to form the word that means 'existing as a natural or essential part of something':	["ehrinhe", "reniheh", "inherent", "herinent"]	inherent	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.238229-04	2025-10-22 20:03:25.346697-04
23	2	2	typing	Type the vocabulary word defined as 'existing as a natural or essential part of something.'	{}	inherent	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.239499-04	2025-10-22 20:03:25.347668-04
24	2	3	definition	Select the best definition of 'inherent'.	["Existing as a natural or essential part of something.", "Developed through learning or habit.", "Accidental or temporary in nature.", "Dependent on outside influence."]	Existing as a natural or essential part of something.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.240446-04	2025-10-22 20:03:25.348798-04
25	3	1	spelling	Unscramble the letters to form the word that means 'done with minimal effort or care':	["fruorynctp", "perfunctory", "punctferory", "perfunctyro"]	perfunctory	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.241926-04	2025-10-22 20:03:25.352826-04
26	3	2	typing	Type the vocabulary word defined as 'done with minimal effort or care.'	{}	perfunctory	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.242973-04	2025-10-22 20:03:25.353582-04
27	3	3	definition	Select the best definition of 'perfunctory'.	["Done with minimal effort or reflection.", "Marked by deep attention and sincerity.", "Performed with excitement and curiosity.", "Built upon careful preparation."]	Done with minimal effort or reflection.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.243944-04	2025-10-22 20:03:25.35436-04
28	4	1	spelling	Unscramble the letters to form the word that means 'lacking focus or organization; spread over a wide area':	["sttshaocret", "scattershot", "stsochatter", "sctthsoater"]	scattershot	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.245106-04	2025-10-22 20:03:25.357037-04
29	4	2	typing	Type the vocabulary word defined as 'lacking focus or organization; spread over a wide area.'	{}	scattershot	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.245936-04	2025-10-22 20:03:25.357722-04
30	4	3	definition	Select the best definition of 'scattershot'.	["Lacking focus or organization; spread over a wide area.", "Precise and carefully targeted.", "Repetitive and predictable in pattern.", "Done secretly or with hesitation."]	Lacking focus or organization; spread over a wide area.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.246665-04	2025-10-22 20:03:25.358337-04
31	5	1	spelling	Unscramble the letters to form the word that means 'to leave out or exclude':	["tiom", "moit", "omit", "itmo"]	omit	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.247756-04	2025-10-22 20:03:25.361013-04
32	5	2	typing	Type the vocabulary word defined as 'to leave out or exclude'.	{}	omit	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.248458-04	2025-10-22 20:03:25.361497-04
33	5	3	definition	Select the best definition of 'omit'.	["To leave out or exclude.", "To include something additional.", "To repeat something unnecessarily.", "To summarize something briefly."]	To leave out or exclude.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.249204-04	2025-10-22 20:03:25.362007-04
34	6	1	spelling	Unscramble the letters to form the word that means 'sticking together; forming a united whole':	["chsieeov", "cohesive", "siecohev", "ceishove"]	cohesive	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.249915-04	2025-10-22 20:03:25.364077-04
35	6	2	typing	Type the vocabulary word defined as 'sticking together; forming a united whole.'	{}	cohesive	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.25057-04	2025-10-22 20:03:25.364535-04
36	6	3	definition	Select the best definition of 'cohesive'.	["Sticking together; forming a united whole.", "Falling apart easily; lacking unity.", "Existing as a separate or detached entity.", "Difficult to understand or explain."]	Sticking together; forming a united whole.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.251173-04	2025-10-22 20:03:25.365059-04
37	7	1	spelling	Unscramble the letters to form the word that means 'most noticeable or important':	["salniet", "lantesi", "salient", "sailent"]	salient	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.2518-04	2025-10-22 20:03:25.366962-04
38	7	2	typing	Type the vocabulary word defined as 'most noticeable or important.'	{}	salient	\N	{"difficulty": "easy"}	10	normal	2025-10-22 20:03:04.252333-04	2025-10-22 20:03:25.367505-04
14	70	2	typing	Type the word you just arranged:	\N	perfunctory	\N	{"case_insensitive": true}	10	normal	2025-10-21 01:45:31.758047-04	2025-10-22 20:07:00.695149-04
43	1	4	synonym	Drag each word into the correct column: synonyms vs. antonyms of 'impede'.	{"antonyms": ["assist", "facilitate", "enable", "advance"], "synonyms": ["obstruct", "delay", "inhibit", "hinder"]}	obstruct, delay, inhibit, hinder	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.34303-04	2025-10-22 20:03:25.34303-04
44	1	5	story	Face the Beast: choose the one statement that best captures the structural essence of 'Impede’s' story.	["He shows how civilization’s movement from body to system replaced morality with mechanism.", "He reveals how physical obstruction always remains moral evil, even in modern forms.", "He symbolizes the triumph of speed over thought.", "He proves that progress depends on removing all friction."]	He shows how civilization’s movement from body to system replaced morality with mechanism.	\N	{"difficulty": "hard", "red_herrings": ["Moral evil is constant across all ages.", "Speed defines virtue in modern society.", "Friction is the enemy of order."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.344881-04	2025-10-22 20:03:25.345846-04
49	2	4	synonym	Sort the following words into synonyms and antonyms of 'inherent'.	{"antonyms": ["extrinsic", "acquired", "external", "incidental"], "synonyms": ["intrinsic", "innate", "essential", "fundamental"]}	intrinsic, innate, essential, fundamental	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.350042-04	2025-10-22 20:03:25.350042-04
50	2	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Inherent’s' story.	["He shows how the idea of what 'belongs within' migrated from matter to morality to identity.", "He reveals that only physical attachment can be truly inherent.", "He symbolizes the loss of external truth in modern philosophy.", "He proves that what is learned is always stronger than what is innate."]	He shows how the idea of what 'belongs within' migrated from matter to morality to identity.	\N	{"difficulty": "hard", "red_herrings": ["Physical attachment defines all belonging.", "External truth outweighs internal nature.", "Learned qualities always surpass innate ones."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.351117-04	2025-10-22 20:03:25.352051-04
55	3	4	synonym	Sort the following words into synonyms and antonyms of 'perfunctory'.	{"antonyms": ["thorough", "diligent", "intentional", "sincere"], "synonyms": ["automatic", "mechanical", "superficial", "unthinking"]}	automatic, mechanical, superficial, unthinking	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.354962-04	2025-10-22 20:03:25.354962-04
56	3	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Perfunctory’s' story.	["He shows how repetition without meaning turns duty into emptiness.", "He proves that efficiency always leads to spiritual depth.", "He reveals that laziness is the source of creativity.", "He symbolizes the triumph of passion over structure."]	He shows how repetition without meaning turns duty into emptiness.	\N	{"difficulty": "hard", "red_herrings": ["Efficiency breeds sincerity.", "Laziness inspires innovation.", "Passion always overrides order."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.355729-04	2025-10-22 20:03:25.356417-04
61	4	4	synonym	Sort the following words into synonyms and antonyms of 'scattershot'.	{"antonyms": ["systematic", "targeted", "methodical", "deliberate"], "synonyms": ["random", "indiscriminate", "unfocused", "erratic"]}	random, indiscriminate, unfocused, erratic	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.358922-04	2025-10-22 20:03:25.358922-04
62	4	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Scattershot’s' story.	["He shows how tools of precision become metaphors for chaos when control fails.", "He proves that randomness is superior to focus.", "He symbolizes that accuracy is meaningless without spontaneity.", "He reveals that intention has no role in human action."]	He shows how tools of precision become metaphors for chaos when control fails.	\N	{"difficulty": "hard", "red_herrings": ["Randomness always produces better outcomes.", "Spontaneity is superior to structure.", "Human intention is irrelevant to order."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.359601-04	2025-10-22 20:03:25.360448-04
39	7	3	definition	Select the best definition of 'salient'.	["Most noticeable or important.", "Hidden or obscure.", "Gradual or subtle in appearance.", "Minor or secondary in nature."]	Most noticeable or important.	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:04.253045-04	2025-10-22 20:03:25.367993-04
67	5	4	synonym	Sort the following words into synonyms and antonyms of 'omit'.	{"antonyms": ["include", "insert", "add", "mention"], "synonyms": ["exclude", "neglect", "skip", "leave out"]}	exclude, neglect, skip, leave out	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.362511-04	2025-10-22 20:03:25.362511-04
68	5	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Omit’s' story.	["He shows how absence becomes its own kind of presence — what is left out shapes meaning as surely as what is said.", "He reveals that forgetting is always accidental.", "He proves that exclusion is morally neutral.", "He symbolizes the end of responsibility in language."]	He shows how absence becomes its own kind of presence — what is left out shapes meaning as surely as what is said.	\N	{"difficulty": "hard", "red_herrings": ["All omission is accidental.", "Exclusion carries no moral weight.", "Responsibility ends once words are spoken."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.363103-04	2025-10-22 20:03:25.363587-04
73	6	4	synonym	Sort the following words into synonyms and antonyms of 'cohesive'.	{"antonyms": ["fragmented", "disjointed", "separate", "divided"], "synonyms": ["united", "bonded", "connected", "integrated"]}	united, bonded, connected, integrated	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.365531-04	2025-10-22 20:03:25.365531-04
74	6	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Cohesive’s' story.	["He shows how the instinct to cling moved from matter to mind—how the same force that binds atoms also binds people.", "He proves that separation is the natural state of all systems.", "He symbolizes the triumph of isolation over union.", "He reveals that emotional attachment weakens structure."]	He shows how the instinct to cling moved from matter to mind—how the same force that binds atoms also binds people.	\N	{"difficulty": "hard", "red_herrings": ["Separation defines stability.", "Isolation produces strength.", "Emotion weakens structure."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.366009-04	2025-10-22 20:03:25.366488-04
79	7	4	synonym	Sort the following words into synonyms and antonyms of 'salient'.	{"antonyms": ["inconspicuous", "minor", "obscure", "unremarkable"], "synonyms": ["prominent", "striking", "notable", "conspicuous"]}	prominent, striking, notable, conspicuous	\N	{"difficulty": "medium"}	15	normal	2025-10-22 20:03:25.368463-04	2025-10-22 20:03:25.368463-04
80	7	5	story	Face the Beast: choose the statement that best captures the structural essence of 'Salient’s' story.	["He shows how what once meant leaping into danger became the mark of what stands out to the eye and mind.", "He reveals that visibility always guarantees truth.", "He symbolizes the loss of depth in a world obsessed with surfaces.", "He proves that importance is a matter of perspective, not presence."]	He shows how what once meant leaping into danger became the mark of what stands out to the eye and mind.	\N	{"difficulty": "hard", "red_herrings": ["Visibility ensures truth.", "Depth always hides weakness.", "Perception defines all reality."], "wager_enabled": true}	50	normal	2025-10-22 20:03:25.368934-04	2025-10-22 20:03:25.369502-04
12	70	6	story	Rebuild the full story of 'perfunctory'—beware the four false centuries. Conquer the beast for double silk.	{"turns": ["He worked among Roman officials who prized completion over feeling.", "He became a prayer said by habit—words without heart.", "He entered English bearing guilt for hollow acts.", "Factories and offices gave him endless routines; he moved without soul.", "He now lives in screens and schedules, still moving, still performing.", "He was adopted by monks to describe joyful labor.", "He symbolized the rational perfection of craft.", "He inspired motivational slogans for workers."], "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Life", "Carolingian Europe", "Enlightenment England", "American Pragmatism"], "red_herrings": ["He was carved into temple inscriptions to bless crops.", "He vanished after Rome's fall, lost to the barbarians.", "He re-emerged during the French Revolution as a virtue.", "He was sung in factories to ward off fatigue."], "time_periods": ["1st c. CE — Rome", "12th c. — Medieval Church", "16th c. — Renaissance Humanism", "19th c. — Industrial Age", "21st c. — Digital Life", "8th c. — Carolingian Europe", "18th c. — Enlightenment England", "20th c. — American Pragmatism"]}	{"1st c. CE — Rome → He worked among Roman officials who prized completion over feeling.","12th c. — Medieval Church → He became a prayer said by habit—words without heart.","16th c. — Renaissance Humanism → He entered English bearing guilt for hollow acts.","19th c. — Industrial Age → Factories and offices gave him endless routines; he moved without soul.","21st c. — Digital Life → He now lives in screens and schedules, still moving, still performing."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-21 01:45:17.309532-04	2025-10-22 20:07:00.702797-04
94	187	1	spelling	Arrange the letters to spell the word:	\N	verisimilitude	\N	\N	10	normal	2025-10-22 20:07:00.704474-04	2025-10-22 20:07:00.704474-04
95	187	2	typing	Type the word you just arranged:	\N	verisimilitude	\N	{"case_insensitive": true}	10	normal	2025-10-22 20:07:00.706215-04	2025-10-22 20:07:00.706215-04
96	187	3	definition	Select all definitions that accurately describe 'verisimilitude':	{"correct_answers": ["The appearance or quality of being true or real", "The quality of seeming to be true or plausible", "Believability or lifelike quality in fiction or art", "The semblance of truth based on probability"], "incorrect_answers": ["Absolute and verifiable truth", "The act of deliberately deceiving others", "Complete accuracy in all factual details", "Objective reality independent of perception", "Scientific proof or empirical evidence", "Honesty and moral integrity", "Exact replication without interpretation", "Divine or absolute certainty"]}	\N	\N	{"feedback": {"fail": "Some held too much certainty; she deals in likeness, not proof.", "hint": "Think of seeming true, not being true.", "success": "You caught the shadow of truth without mistaking it for the light."}, "min_correct_to_pass": 3, "shuffle_each_attempt": true}	15	normal	2025-10-22 20:07:00.707478-04	2025-10-22 20:07:00.707478-04
97	187	4	synonym	Drag each word into the correct basket for 'verisimilitude':	{"antonyms": ["implausibility", "incredibility", "unreality", "falseness"], "synonyms": ["plausibility", "believability", "realism", "credibility"], "red_herrings": ["accuracy", "honesty", "certainty", "verification"]}	\N	\N	{"feedback": {"fail": "Some words claimed too much—or too little—truth.", "hint": "She resembles truth but isn't its twin.", "success": "You sorted appearance from substance with precision."}, "min_correct_to_pass": 6, "shuffle_each_attempt": true}	15	normal	2025-10-22 20:07:00.708696-04	2025-10-22 20:07:00.708696-04
98	187	5	story	Match each time period with its stage in the story of 'verisimilitude', then arrange them in order:	{"turns": ["She was born in rhetoric—the orator's art of seeming true when proof was distant.", "She became the soul of narrative—what made fiction teach by feeling real.", "She arrived in England as the measure of art—not truth, but its convincing performance.", "Realists demanded research and detail; she grew exacting, almost scientific.", "In courtrooms and cinema, she became evidence and spectacle—belief without certainty.", "Now she moves through deepfakes and virtual worlds, engineering the feeling of truth."], "settings": ["Rome", "Medieval Scholarship", "English Enlightenment", "Realist Movement", "Modern Media", "Digital Age"], "time_periods": ["1st c. CE", "14th c.", "17th c.", "19th c.", "20th c.", "21st c."]}	{"1st c. CE — Rome → She was born in rhetoric—the orator's art of seeming true when proof was distant.","14th c. — Medieval Scholarship → She became the soul of narrative—what made fiction teach by feeling real.","17th c. — English Enlightenment → She arrived in England as the measure of art—not truth, but its convincing performance.","19th c. — Realist Movement → Realists demanded research and detail; she grew exacting, almost scientific.","20th c. — Modern Media → In courtrooms and cinema, she became evidence and spectacle—belief without certainty.","21st c. — Digital Age → Now she moves through deepfakes and virtual worlds, engineering the feeling of truth."}	\N	{"feedback": {"fail": "Some stages slipped out of sequence.", "hint": "Trace how likeness evolved from rhetoric to technology.", "success": "The centuries align—truth's shadow comes into focus."}, "allow_partial_credit": true, "shuffle_each_attempt": true}	25	normal	2025-10-22 20:07:00.70975-04	2025-10-22 20:07:00.70975-04
99	187	6	story	Rebuild the full story of 'verisimilitude'—beware the five false centuries. Conquer the beast for double silk.	{"turns": ["She was born in rhetoric—the orator's art of seeming true when proof was distant.", "She became the soul of narrative—what made fiction teach by feeling real.", "She arrived in England as the measure of art—not truth, but its convincing performance.", "Realists demanded research and detail; she grew exacting, almost scientific.", "In courtrooms and cinema, she became evidence and spectacle—belief without certainty.", "Now she moves through deepfakes and virtual worlds, engineering the feeling of truth.", "She was worshipped as a goddess of wisdom in Byzantine temples.", "She traveled the Silk Road as a merchant's guarantee of quality.", "She became a painter's technique for perfect perspective.", "She was debated in salons as the measure of moral virtue.", "She was banned by reformers as a form of Catholic deceit."], "settings": ["Rome", "Medieval Scholarship", "English Enlightenment", "Realist Movement", "Modern Media", "Digital Age", "Byzantine Empire", "Islamic Golden Age", "Italian Renaissance", "French Salons", "Protestant Reformation"], "red_herrings": ["She inspired medieval illuminated manuscripts depicting truth as light.", "She was encoded in Renaissance geometry as divine proportion.", "She emerged in Romantic poetry as nature's authentic voice.", "She became a Victorian virtue signaling moral character.", "She was rejected by modernists as bourgeois pretense."], "time_periods": ["1st c. CE — Rome", "14th c. — Medieval Scholarship", "17th c. — English Enlightenment", "19th c. — Realist Movement", "20th c. — Modern Media", "21st c. — Digital Age", "5th c. — Byzantine Empire", "11th c. — Islamic Golden Age", "15th c. — Italian Renaissance", "18th c. — French Salons", "16th c. — Protestant Reformation"]}	{"1st c. CE — Rome → She was born in rhetoric—the orator's art of seeming true when proof was distant.","14th c. — Medieval Scholarship → She became the soul of narrative—what made fiction teach by feeling real.","17th c. — English Enlightenment → She arrived in England as the measure of art—not truth, but its convincing performance.","19th c. — Realist Movement → Realists demanded research and detail; she grew exacting, almost scientific.","20th c. — Modern Media → In courtrooms and cinema, she became evidence and spectacle—belief without certainty.","21st c. — Digital Age → Now she moves through deepfakes and virtual worlds, engineering the feeling of truth."}	\N	{"feedback": {"fail": "The beast of confusion claimed you. Truth's likeness remains hidden.", "hint": "Illusions multiply—seek the thread from rhetoric to simulation.", "success": "You have pierced the veil of false centuries. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:07:00.710788-04	2025-10-22 20:07:00.710788-04
100	1	6	story	Rebuild the full story of 'impede'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.", "When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.", "Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.", "By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine.", "He was adopted by Charlemagne's scribes to describe the weight of imperial decrees.", "He became a battle cry for knights charging into holy war.", "He symbolized the rational perfection of bureaucratic order."], "settings": ["Rome", "Medieval Christianity", "Renaissance Humanism", "Industrial Age", "Carolingian Empire", "Crusades", "Enlightenment"], "red_herrings": ["He was carved into temple inscriptions to bless crops.", "He vanished after Rome's fall, lost to the barbarians.", "He re-emerged during the French Revolution as a virtue."], "time_periods": ["1st c. CE", "14th c.", "16th c.", "19th c.", "8th c.", "12th c.", "18th c."]}	{"1st c. CE — Rome → Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.","14th c. — Medieval Christianity → When the Empire's dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.","16th c. — Renaissance Humanism → Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat's delay, the inventor's frustration, the scholar's pause.","19th c. — Industrial Age → By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.297397-04	2025-10-22 20:18:20.297397-04
101	13	6	story	Rebuild the full story of 'inherent'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.", "In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.", "When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.", "Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together.", "He was adopted by Carolingian monks to describe the divine spark in all creation.", "He became the cornerstone of scholastic debates about essence and accident.", "He symbolized the romantic notion of natural genius and inspiration."], "settings": ["Rome", "Medieval Philosophy", "Enlightenment", "Modern Science", "Carolingian Renaissance", "Scholasticism", "Romantic Era"], "red_herrings": ["He was worshipped as a god of natural order in pagan temples.", "He vanished during the Dark Ages, lost to barbarian ignorance.", "He re-emerged during the Renaissance as a principle of artistic beauty."], "time_periods": ["1st c. CE", "14th c.", "17th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	{"1st c. CE — Rome → In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.","14th c. — Medieval Philosophy → In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle's logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.","17th c. — Enlightenment → When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.","20th c. — Modern Science → Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.303904-04	2025-10-22 20:18:20.303904-04
102	27	6	story	Rebuild the full story of 'cohesive'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.", "When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.", "The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.", "Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary.", "He was adopted by Carolingian architects to describe the unity of stone and mortar.", "He became the motto of medieval guilds celebrating craft unity.", "He symbolized the romantic ideal of organic social harmony."], "settings": ["Rome", "Scientific Revolution", "Industrial Age", "Modern Management", "Carolingian Empire", "Medieval Guilds", "Romantic Movement"], "red_herrings": ["He was carved into cathedral walls as a symbol of divine unity.", "He vanished during the Reformation, lost to Protestant individualism.", "He re-emerged during the Renaissance as a principle of artistic composition."], "time_periods": ["1st c. CE", "17th c.", "19th c.", "20th c.", "8th c.", "12th c.", "18th c."]}	{"1st c. CE — Rome → In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.","17th c. — Scientific Revolution → When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.","19th c. — Industrial Age → The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.","20th c. — Modern Management → Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.307635-04	2025-10-22 20:18:20.307635-04
103	42	6	story	Rebuild the full story of 'scattershot'—beware the two false centuries. Conquer the beast for double silk.	{"turns": ["In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.", "After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.", "Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once.", "He was adopted by Renaissance artists to describe experimental painting techniques.", "He symbolized the Enlightenment ideal of spreading knowledge widely."], "settings": ["American Frontier", "Postwar Era", "Digital Age", "Renaissance", "Enlightenment"], "red_herrings": ["He was carved into colonial coins as a symbol of American independence.", "He vanished during the Civil War, lost to the precision of modern warfare."], "time_periods": ["19th c.", "20th c.", "21st c.", "16th c.", "18th c."]}	{"19th c. — American Frontier → In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun's mouth. It was a hunter's word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.","20th c. — Postwar Era → After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.","21st c. — Digital Age → Now he's everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.312283-04	2025-10-22 20:18:20.312283-04
104	56	6	story	Rebuild the full story of 'salient'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *saliēns*—'leaping, springing forth.' The poets used him for fountains, fish, the pulse of joy. To leap was to live: the verb *salīre* carried vitality itself. Salient began as motion, not metaphor.", "By the Renaissance, *saillant* in French meant 'jutting out'—a wall that leaned toward the world, a bastion pointing at the horizon. English borrowed him as an engineer's and soldier's term: the salient angle of a fortress, the place that struck first and was struck hardest.", "Then the leap turned inward. Philosophers and rhetoricians called an idea 'salient' when it sprang to the mind. The fortification became a thought: something projecting beyond the rest. To leap became to signify.", "By the modern age, Salient had settled into analysis and argument. He no longer moved; he marked. To be salient was to stand out by design, not by motion. Yet in every use, his ancient spring survives—the mind's leap made permanent in language.", "He was adopted by Carolingian architects to describe cathedral spires.", "He became the motto of medieval knights celebrating chivalric valor.", "He symbolized the romantic ideal of spontaneous inspiration."], "settings": ["Rome", "Renaissance Architecture", "Early Philosophy", "Modern Analysis", "Carolingian Empire", "Medieval Courts", "Romantic Poetry"], "red_herrings": ["He was carved into temple pillars as a symbol of divine revelation.", "He vanished during the Dark Ages, lost to monastic contemplation.", "He re-emerged during the Renaissance as a principle of artistic perspective."], "time_periods": ["1st c. CE", "16th c.", "17th c.", "19th c.", "8th c.", "12th c.", "18th c."]}	{"1st c. CE — Rome → In Rome, he was *saliēns*—'leaping, springing forth.' The poets used him for fountains, fish, the pulse of joy. To leap was to live: the verb *salīre* carried vitality itself. Salient began as motion, not metaphor.","16th c. — Renaissance Architecture → By the Renaissance, *saillant* in French meant 'jutting out'—a wall that leaned toward the world, a bastion pointing at the horizon. English borrowed him as an engineer's and soldier's term: the salient angle of a fortress, the place that struck first and was struck hardest.","17th c. — Early Philosophy → Then the leap turned inward. Philosophers and rhetoricians called an idea 'salient' when it sprang to the mind. The fortification became a thought: something projecting beyond the rest. To leap became to signify.","19th c. — Modern Analysis → By the modern age, Salient had settled into analysis and argument. He no longer moved; he marked. To be salient was to stand out by design, not by motion. Yet in every use, his ancient spring survives—the mind's leap made permanent in language."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.314501-04	2025-10-22 20:18:20.314501-04
105	83	6	story	Rebuild the full story of 'omit'—beware the three false centuries. Conquer the beast for double silk.	{"turns": ["In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.", "In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.", "When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.", "With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.", "Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame.", "He was adopted by Carolingian scribes to describe the art of diplomatic silence.", "He symbolized the Enlightenment ideal of rational restraint and precision."], "settings": ["Rome", "Medieval Theology", "Late Medieval Bureaucracy", "Renaissance Printing", "Modern English", "Carolingian Empire", "Enlightenment"], "red_herrings": ["He was carved into temple inscriptions as a warning against neglect.", "He vanished during the Reformation, lost to Protestant emphasis on action.", "He re-emerged during the Renaissance as a principle of artistic economy."], "time_periods": ["1st c. CE", "12th c.", "15th c.", "16th c.", "20th c.", "8th c.", "18th c."]}	{"1st c. CE — Rome → In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.","12th c. — Medieval Theology → In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.","15th c. — Late Medieval Bureaucracy → When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.","16th c. — Renaissance Printing → With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.","20th c. — Modern English → Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame."}	\N	{"feedback": {"fail": "The beast devoured your certainty. Try again.", "hint": "Some centuries whisper lies.", "success": "You have slain the beast of confusion. Double silk earned."}, "hard_mode_penalty": {"health_loss_on_fail": 2, "reward_multiplier_on_success": 2}, "allow_partial_credit": false, "shuffle_each_attempt": true}	50	hard	2025-10-22 20:18:20.316637-04	2025-10-22 20:18:20.316637-04
\.


--
-- Data for Name: quizzes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quizzes (id, user_id, word_id, current_level, is_active, started_at, completed_at, hard_mode, wager_amount, hard_mode_completed) FROM stdin;
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, floor_id, word_id, room_number, name, description, silk_cost, silk_reward, is_boss_room, created_at) FROM stdin;
129	25	\N	9	Floor Guardian Chamber	Only those with the language to describe the world to come will be admitted to go on—those who are worthy, those who are equipped for future battle, those who know the true names of things.	0	100	t	2025-10-24 20:04:52.359355-04
130	26	443	1	Room of Attest	Master the word "attest" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.138456-04
131	26	511	2	Room of Elucidate	Master the word "elucidate" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.144244-04
132	26	469	3	Room of Lumbering	Master the word "lumbering" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.145014-04
133	26	457	4	Room of Pall	Master the word "pall" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.145703-04
134	26	527	5	Room of Plausible	Master the word "plausible" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.146539-04
135	26	483	6	Room of Scurry	Master the word "scurry" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.147381-04
136	26	496	7	Room of Steadfast	Master the word "steadfast" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.148302-04
137	26	542	8	Room of Ubiquitous	Master the word "ubiquitous" through story, quiz, and challenge.	10	15	f	2025-10-28 03:50:57.149049-04
138	26	\N	9	Floor Guardian Chamber	The guardian of this floor awaits. Only those who have mastered all eight words may proceed.	0	0	t	2025-10-28 03:50:57.150346-04
128	25	187	8	Room of verisimilitude	The Floor Guardian chamber. Only those who have mastered all words on this floor may challenge them.	0	100	f	2025-10-24 16:57:43.458257-04
121	25	1	1	Room of impede	A chamber containing the ancient word "impede". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.449076-04
122	25	13	2	Room of inherent	A chamber containing the ancient word "inherent". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.450788-04
123	25	27	3	Room of cohesive	A chamber containing the ancient word "cohesive". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.452298-04
124	25	42	4	Room of scattershot	A chamber containing the ancient word "scattershot". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.453792-04
125	25	56	5	Room of salient	A chamber containing the ancient word "salient". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.454959-04
126	25	83	6	Room of omit	A chamber containing the ancient word "omit". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.456214-04
127	25	70	7	Room of perfunctory	A chamber containing the ancient word "perfunctory". Unlock this room to access all quizzes for this word, including Beast Mode challenges.	25	15	f	2025-10-24 16:57:43.457322-04
\.


--
-- Data for Name: root_families; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.root_families (id, root_word, language, gloss) FROM stdin;
1	mittere	Latin	to send, let go, release
\.


--
-- Data for Name: semantic_domains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.semantic_domains (id, name, description) FROM stdin;
4	military	Fortifications, tactics, logistics
1	legal	Law, courts, contracts, administrative codes
2	moral	Ethics, theology, sin/guilt/virtue
3	editorial	Textual acts, print culture, rhetoric
6	bureaucratic	Records, forms, administrative procedure
5	scientific	Standardized prose, technical registers
\.


--
-- Data for Name: silk_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.silk_transactions (id, user_id, quiz_id, amount, transaction_type, description, created_at) FROM stdin;
\.


--
-- Data for Name: story_comprehension_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.story_comprehension_questions (id, word_id, century, question, options, correct_answer, explanation, created_at, updated_at) FROM stdin;
200	443	1	What did the word 'testare' originally mean in Roman law?	["To stand and speak as a witness", "To write official documents", "To judge court cases", "To enforce legal penalties"]	To stand and speak as a witness	The text explicitly states that 'testare' meant 'to bear witness' and describes how 'three witnesses' were required to stand and speak what they had seen.	2025-10-27 14:08:42.085349-04	2025-10-27 14:08:42.085349-04
201	443	14	How did the meaning of 'attest' change when it entered English courts?	["It shifted from spoken testimony to written proof", "It became more casual and informal", "It lost all legal significance", "It referred only to religious oaths"]	It shifted from spoken testimony to written proof	The text explains that attest 'moved from spoken truth to written proof' and describes how witnesses' words 'lived on in ink.'	2025-10-27 14:08:42.08815-04	2025-10-27 14:08:42.08815-04
202	443	17	How did print culture change what it meant to 'attest' to something?	["It made testimony public and reputational, adding risk of public error", "It made testimony less important and easier to give", "It eliminated the need for witnesses entirely", "It made attestation automatic and without consequence"]	It made testimony public and reputational, adding risk of public error	The text states that 'print multiplied voices' and that to attest meant 'to stake one's name on it,' learning 'the weight of reputation—the risk of being wrong in public.'	2025-10-27 14:08:42.089034-04	2025-10-27 14:08:42.089034-04
203	443	19	How did attestation change in the industrial age?	["Personal testimony became routine, formal documentation", "It became more dramatic and emotional", "It was abolished entirely", "It became more personal and less formal"]	Personal testimony became routine, formal documentation	The text explains that Attest 'grew quieter, more technical' and that 'the standing witness became a form to sign, a seal to affix'—moving from personal truth to 'the system's record.'	2025-10-27 14:08:42.089943-04	2025-10-27 14:08:42.089943-04
204	457	9	What was the original meaning of 'pæll' in Old English?	["A rich cloak or ceremonial fabric", "A mourning shroud", "A carpet or floor covering", "A type of armor"]	A rich cloak or ceremonial fabric	The text explicitly states that 'he meant 'a cloak'—rich fabric draped over shoulders' and gives examples of 'Kings wore palls of purple; saints were buried under palls of silk.'	2025-10-27 14:08:42.09145-04	2025-10-27 14:08:42.09145-04
205	457	14	How did the meaning of 'pall' shift during medieval plague times?	["It changed from luxury fabric to funeral shroud", "It became only for rich people", "It lost all meaning", "It became a symbol of celebration"]	It changed from luxury fabric to funeral shroud	The text states that 'He became the ritual cloth of separation' and explicitly notes 'From rich cloak to funeral shroud, luxury became dignity in death.'	2025-10-27 14:08:42.092428-04	2025-10-27 14:08:42.092428-04
206	457	17	How did poets transform the meaning of 'pall' in the 17th century?	["They expanded it from literal cloth to metaphorical atmosphere", "They made it only mean literal funeral cloth", "They gave it a positive, joyful meaning", "They made it disappear from the language"]	They expanded it from literal cloth to metaphorical atmosphere	The text explains that 'He had learned to stretch—no longer just cloth but anything heavy, dark, settling' and that 'He became atmosphere: the feeling of weight that comes from nowhere visible.'	2025-10-27 14:08:42.093457-04	2025-10-27 14:08:42.093457-04
207	457	19	What new meaning did 'pall' gain as a verb in the Victorian era?	["To become tiresome or lose interest", "To cause great excitement", "To become physically stronger", "To disappear completely"]	To become tiresome or lose interest	The text states that 'The joke palled; the beauty palled; repetition palled everything' and describes how it represents 'weariness' and 'boredom'—the 'gentle killing of interest.'	2025-10-27 14:08:42.09442-04	2025-10-27 14:08:42.09442-04
208	469	14	What did 'lumber' originally mean when it came from Lombard merchants?	["Goods stored as pawn in a shop", "Walking slowly", "Cutting down trees", "Moving machinery"]	Goods stored as pawn in a shop	The text explicitly states that lumber meant 'pawn, goods stored in a Lombard's shop' and describes it as 'stored things, cluttering the space.'	2025-10-27 14:08:42.09567-04	2025-10-27 14:08:42.09567-04
209	469	16	How did lumbering connect to colonial exploration?	["It came to mean cutting and moving heavy timber", "It became a peaceful trading term", "It lost all connection to heavy objects", "It referred only to silver and gold"]	It came to mean cutting and moving heavy timber	The text states that 'Lumber came to mean timber, and to lumber meant to cut it clumsily, to move it heavily' and that 'the word that named stored goods now named fallen trees.'	2025-10-27 14:08:42.096422-04	2025-10-27 14:08:42.096422-04
210	469	18	How did naturalists transform the meaning of 'lumbering'?	["They used it to describe heavy, deliberate animal movement", "They made it mean graceful and swift movement", "They used it only for small, light animals", "They applied it to human emotions"]	They used it to describe heavy, deliberate animal movement	The text states that 'The bear lumbered through snow; the elephant lumbered into the clearing' and describes this as 'the honest gait of mass: each step deliberate, ground-giving.'	2025-10-27 14:08:42.097119-04	2025-10-27 14:08:42.097119-04
211	469	19	What did lumbering represent in the industrial age?	["Massive, powerful machinery that was awkward but unstoppable", "Small, delicate tools", "Peaceful, silent operation", "Old-fashioned, unimportant technology"]	Massive, powerful machinery that was awkward but unstoppable	The text states that 'Lumbering trains; lumbering factories; lumbering machines that shook the earth' and describes it as 'cumbersome but inevitable, awkward but unstoppable.'	2025-10-27 14:08:42.097825-04	2025-10-27 14:08:42.097825-04
212	483	17	Where did 'scurry' come from and what did it originally describe?	["From great houses, describing confused, rushed servant movement", "From battlefields, describing heroic charges", "From monasteries, describing prayerful processions", "From shipyards, describing careful construction"]	From great houses, describing confused, rushed servant movement	The text explicitly states that 'In the great houses of England, he was born from *hurry-scurry*' and describes 'servants running to orders that canceled each other out.'	2025-10-27 14:08:42.098888-04	2025-10-27 14:08:42.098888-04
213	483	19	What did 'scurry' convey when applied to human workers?	["Hurried movement without dignity or power", "Regal, important movement", "Peaceful, meditative movement", "Large, sweeping gestures"]	Hurried movement without dignity or power	The text explicitly states that it 'suggested movement without dignity—hurried but not powerful, busy but not significant.'	2025-10-27 14:08:42.100556-04	2025-10-27 14:08:42.100556-04
215	483	20	How has 'scurry' been transformed in modern, digital culture?	["It describes constant mental distraction and never-still attention", "It has become obsolete and unused", "It means peaceful meditation", "It describes slow, careful thought"]	It describes constant mental distraction and never-still attention	The text explains that 'attention itself scurried from device to device' and that it represents 'never still, never settled, always moving to the next thing'—'the perpetual hurry of being that cannot stop.'	2025-10-27 14:08:42.101722-04	2025-10-27 14:08:42.101722-04
216	496	9	What did 'stædfæst' originally mean in Old English?	["Firm in place, physically fixed", "Quick and agile", "Weak and uncertain", "Moving constantly"]	Firm in place, physically fixed	The text explicitly states that 'stædfæst' meant 'firm in place' and describes it as 'a standing-ground' and 'fixed'—showing physical position before moral loyalty.	2025-10-27 14:08:42.103314-04	2025-10-27 14:08:42.103314-04
217	496	14	How did medieval chivalry transform the meaning of steadfastness?	["Physical holding in battle became moral holding in vows and loyalty", "It lost all meaning and importance", "It became purely physical without moral dimension", "It meant being flexible and changing loyalties"]	Physical holding in battle became moral holding in vows and loyalty	The text states that 'What began as physical holding became moral holding' and that 'Fealty, faith, friendship—all required steadfastness'—showing the shift from 'standing' to 'staying.'	2025-10-27 14:08:42.103911-04	2025-10-27 14:08:42.103911-04
218	496	17	How did Renaissance poets transform steadfastness?	["Military courage became romantic fidelity and devotion", "It became a negative quality", "It lost all connection to love", "It meant changing partners frequently"]	Military courage became romantic fidelity and devotion	The text states that 'What began as military courage became romantic fidelity' and describes 'not just loyalty but devotion, not just persistence but passion that endures.'	2025-10-27 14:08:42.104489-04	2025-10-27 14:08:42.104489-04
219	496	19	What did the Romantics say about steadfastness and personal identity?	["It became authentic selfhood and personal integrity", "It was rejected as old-fashioned", "It meant conforming to social expectations", "It had no connection to identity"]	It became authentic selfhood and personal integrity	The text states that 'Steadfastness became not just virtue but identity—the self that knows itself and holds' and describes it as 'authenticity: not stubbornness but integrity.'	2025-10-27 14:08:42.104992-04	2025-10-27 14:08:42.104992-04
220	511	1	What was the original Latin meaning of 'lūcidus' and what did it describe?	["Bright, shining, clear; describing transparent things and clear thoughts", "Dark and mysterious things", "Heavy and weighty objects", "Hidden and secret things"]	Bright, shining, clear; describing transparent things and clear thoughts	The text explicitly states that 'lūcidus' meant 'bright, shining, clear' and describes it as shining with 'inner clarity—water you could see through, thoughts that had no shadows.'	2025-10-27 14:08:42.10584-04	2025-10-27 14:08:42.10584-04
221	511	16	How did Renaissance scholars transform 'elucidate' from a quality to an action?	["They formed it as a verb meaning 'to make luminous'—turning the quality of brightness into the act of casting light", "They made it mean 'to make darker and more obscure'", "They used it only for physical objects", "They abandoned its connection to light"]	They formed it as a verb meaning 'to make luminous'—turning the quality of brightness into the act of casting light	The text states that scholars formed '*ēlūcidātum*—'to make luminous'' and 'The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.'	2025-10-27 14:08:42.106349-04	2025-10-27 14:08:42.106349-04
222	511	18	What role did 'elucidate' play in Enlightenment philosophy?	["It became the verb of understanding—using reason to illuminate nature, history, and the human mind", "It became only about religious revelation", "It lost connection to knowledge", "It meant creating more mystery"]	It became the verb of understanding—using reason to illuminate nature, history, and the human mind	The text states that 'Thinkers vowed to elucidate nature, history, the human mind' and that 'He became the verb of understanding—not faith but illumination, not mystery but method.'	2025-10-27 14:08:42.106833-04	2025-10-27 14:08:42.106833-04
223	511	20	How has 'elucidate' changed in modern educational discourse?	["It became routine procedure rather than revelation—ordinary explanation rather than illumination", "It became more mysterious and obscure", "It lost all connection to clarity", "It became only used in poetry"]	It became routine procedure rather than revelation—ordinary explanation rather than illumination	The text states 'To elucidate is still to bring light, but the light itself has grown ordinary' and that 'he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark.'	2025-10-27 14:08:42.107299-04	2025-10-27 14:08:42.107299-04
224	527	1	What was the original Latin meaning of 'plaudibilis' and how was it used?	["Worthy of applause; measuring what audiences approved through sound rather than truth", "Worthy of absolute truth and certainty", "Hidden from audiences", "Meant only for written documents"]	Worthy of applause; measuring what audiences approved through sound rather than truth	The text states that 'plaudibilis' meant 'worthy of applause' and 'She was theater's judgment: not truth but approval, not reality but acceptance.'	2025-10-27 14:08:42.108729-04	2025-10-27 14:08:42.108729-04
225	527	17	How did Enlightenment philosophy transform 'plausible'?	["It moved from audience applause to rational approval—reasonable minds accepting what's not obviously false", "It became only about absolute certainty", "It lost all connection to reason", "It meant the same as mathematical proof"]	It moved from audience applause to rational approval—reasonable minds accepting what's not obviously false	The text states that 'Plausible moved from theater to philosophy' and that 'She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false.'	2025-10-27 14:08:42.109309-04	2025-10-27 14:08:42.109309-04
226	527	19	How did Victorian society transform 'plausible'?	["It became about social respectability and proper public appearances", "It became purely about mathematical certainty", "It lost all connection to society", "It meant only for criminal justice"]	It became about social respectability and proper public appearances	The text states that 'To be plausible meant to seem respectable, to wear the mask of propriety' and that 'Her truth became social acceptability, measured in frowns averted, suspicions eased.'	2025-10-27 14:08:42.109921-04	2025-10-27 14:08:42.109921-04
227	527	20	How does 'plausible' function in modern discourse?	["It operates as currency—the middle ground between lies and certainty, serving those who need belief without proof", "It means absolute scientific proof", "It has no modern function", "It refers only to physical objects"]	It operates as currency—the middle ground between lies and certainty, serving those who need belief without proof	The text states that 'plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable' and that 'She has learned to serve whoever needs belief without proof—the master of appearances.'	2025-10-27 14:08:42.110557-04	2025-10-27 14:08:42.110557-04
163	1	1	What was the original Roman meaning of 'impedire' based on its etymology?	["To shackle the feet", "To speed up movement", "To create obstacles", "To bind the hands"]	To shackle the feet	The text explicitly states that 'impedire' meant 'to shackle the feet,' built from 'in-' (upon) and 'pes/pedis' (foot).	2025-10-27 14:08:23.739915-04	2025-10-27 14:08:23.739915-04
164	1	14	How did Christianity transform the meaning of 'impede' in the 14th century?	["It became purely physical obstruction", "It became spiritual stumbling and sin", "It became a tool for priests", "It became a military strategy"]	It became spiritual stumbling and sin	The text explains that 'the soul now had feet' and 'to sin was to stumble,' showing how physical obstruction became spiritual metaphor.	2025-10-27 14:08:23.746815-04	2025-10-27 14:08:23.746815-04
165	1	16	What changed about 'impede' during the Renaissance period?	["It became more evil and dangerous", "It shifted from bodies to minds and became inconvenient rather than evil", "It became purely physical again", "It was completely forgotten"]	It shifted from bodies to minds and became inconvenient rather than evil	The text states that 'motion itself became a metaphor' and 'Impede...now followed minds instead of bodies. He was no longer evil, just inconvenient.'	2025-10-27 14:08:23.748624-04	2025-10-27 14:08:23.748624-04
166	1	19	How did the industrial age transform 'impede'?	["It became more moral and spiritual", "It lost moral meaning and became mechanical inefficiency", "It returned to its original physical meaning", "It became a positive force for progress"]	It lost moral meaning and became mechanical inefficiency	The text states 'The moral heat was gone—only procedure remained' and describes how it 'haunted the gears of systems,' showing the shift from moral to mechanical.	2025-10-27 14:08:23.749698-04	2025-10-27 14:08:23.749698-04
167	13	1	What was the original Latin meaning of 'inhaerēre' and how was it used?	["To stick in or cling to physically; used by philosophers to describe properties within matter", "To separate or divide things", "To hide or conceal objects", "To move rapidly away from something"]	To stick in or cling to physically; used by philosophers to describe properties within matter	The text states 'inhaerēre' meant 'to stick in, to cling to' and gives physical examples, then shows 'Philosophers used him to name qualities that lived inside matter itself.'	2025-10-27 14:08:23.751477-04	2025-10-27 14:08:23.751477-04
168	13	14	How did medieval scholars use 'inherent' in philosophical discourse?	["They used it to describe qualities that could never be separated from their substance (virtue in soul, whiteness in snow)", "They used it to mean qualities that could be easily removed", "They used it only to describe physical objects", "They stopped using it entirely"]	They used it to describe qualities that could never be separated from their substance (virtue in soul, whiteness in snow)	The text states 'Virtue was said to inhere in the soul; whiteness to inhere in snow' and 'He spoke of what could never be separated from what it was.'	2025-10-27 14:08:23.752454-04	2025-10-27 14:08:23.752454-04
169	13	17	What happened to 'inherent' during the Enlightenment?	["It moved from metaphysics to politics, describing rights and dignity as qualities that belonged naturally to humans", "It became purely religious", "It returned to describing only physical objects", "It lost all meaning"]	It moved from metaphysics to politics, describing rights and dignity as qualities that belonged naturally to humans	The text states 'He began to speak of rights and dignity—qualities not bestowed but possessed' and 'He became political, carrying the old logic of internal belonging into the language of freedom.'	2025-10-27 14:08:23.753511-04	2025-10-27 14:08:23.753511-04
170	13	20	How is 'inherent' used in modern scientific and technical discourse?	["To describe structural properties (bias in data, stability in molecules) where the logic of 'belonging within' endures", "To describe qualities that can be easily removed or changed", "Only in poetry and literature", "To mean the opposite of what belongs naturally"]	To describe structural properties (bias in data, stability in molecules) where the logic of 'belonging within' endures	The text shows 'the inherent bias of data, the inherent stability of molecules' where 'what belongs within still holds everything together' - structural properties maintain the concept of internal belonging.	2025-10-27 14:08:23.75491-04	2025-10-27 14:08:23.75491-04
171	27	1	What was the original Latin meaning of 'cohaerēre'?	["To stick together physically (glue, sap, wax) and metaphorically (friends)", "To separate things apart", "To mean only mental concepts", "To describe warfare exclusively"]	To stick together physically (glue, sap, wax) and metaphorically (friends)	The text states 'cohaerēre' meant 'to stick together' and shows physical examples (glue, sap, wax, brick to mortar) as well as metaphorical ones (friend to friend).	2025-10-27 14:08:23.756253-04	2025-10-27 14:08:23.756253-04
172	27	17	How did the scientific revolution transform 'cohesive'?	["It became a physical law describing the force that binds particles and atoms together", "It lost all scientific meaning", "It became only about human relationships", "It referred only to liquids"]	It became a physical law describing the force that binds particles and atoms together	The text states 'He became a principle, not just a feeling' and 'Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.'	2025-10-27 14:08:23.757229-04	2025-10-27 14:08:23.757229-04
173	27	19	How did the industrial age expand the meaning of 'cohesive'?	["It extended from physical science to describe social and intellectual unity (nations, crowds, stories, minds)", "It became only about machines", "It returned to physical objects only", "It lost all connection to unity"]	It extended from physical science to describe social and intellectual unity (nations, crowds, stories, minds)	The text shows 'Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.'	2025-10-27 14:08:23.758468-04	2025-10-27 14:08:23.758468-04
174	27	20	How is 'cohesive' used in modern organizational and design contexts?	["To describe the integration and unity of teams, arguments, and designs that hold together", "To mean the opposite of united", "Only in scientific contexts", "To describe things that fall apart"]	To describe the integration and unity of teams, arguments, and designs that hold together	The text shows 'Now Cohesive lives in offices and classrooms, in design briefs and mission statements' and 'Every time a team holds, or an argument flows, he's there—quiet, connecting, necessary.'	2025-10-27 14:08:23.759703-04	2025-10-27 14:08:23.759703-04
175	42	19	What was the original meaning of 'scattershot' in 1800s frontier America?	["The spray of pellets from a shotgun, sacrificing precision for range", "A precise, aimed single shot", "A military strategy for urban warfare", "A term for gathering crops"]	The spray of pellets from a shotgun, sacrificing precision for range	The text states that 'scattershot' was 'pure mechanics: the spray of pellets from a shotgun's mouth' and 'meaning range at the cost of precision.'	2025-10-27 14:08:23.760874-04	2025-10-27 14:08:23.760874-04
176	42	20	How did postwar culture transform 'scattershot'?	["From physical pellets to describing unfocused ideas, policies, and arguments", "It became only about shotgun hunting", "It became synonymous with precision", "It disappeared entirely"]	From physical pellets to describing unfocused ideas, policies, and arguments	The text states 'He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider' and 'The old gunmetal word now measured intellectual mess.'	2025-10-27 14:08:23.761505-04	2025-10-27 14:08:23.761505-04
177	42	21	How is 'scattershot' used in contemporary culture?	["To describe unfocused, hasty effort that tries to address everything without clear strategy", "To mean precise and targeted", "Only in hunting contexts", "To describe successful, well-planned approaches"]	To describe unfocused, hasty effort that tries to address everything without clear strategy	The text shows 'Scattershot speaks of the rush to do, to say, to solve before thinking' and 'the price of trying to hit everything at once' - describing unfocused effort.	2025-10-27 14:08:23.762212-04	2025-10-27 14:08:23.762212-04
178	56	1	What was the original Latin meaning of 'saliēns'?	["Leaping or springing forth physically", "Being important or prominent", "Being hidden or obscure", "Being slow or delayed"]	Leaping or springing forth physically	The text explicitly states that 'saliēns' meant 'leaping, springing forth' and gives examples of 'fountains, fish, and joy itself' - all physical motion.	2025-10-27 14:08:23.763316-04	2025-10-27 14:08:23.763316-04
179	56	12	How did Old French transform 'salient' from physical motion?	["It connected physical motion to visibility and projection in military/architectural contexts", "It lost all connection to motion", "It became purely about hiding things", "It referred only to farming tools"]	It connected physical motion to visibility and projection in military/architectural contexts	The text shows how 'saillir' meant 'to leap, to project' and 'saillant' described 'what thrust forward — a wall, a knight, a beast on a shield,' connecting motion to visibility and projection.	2025-10-27 14:08:23.764419-04	2025-10-27 14:08:23.764419-04
180	56	16	What did Renaissance English use 'salient' to describe?	["Things that jutted out — both physical (bastions) and symbolic (arguments)", "Only physical buildings", "Only abstract ideas", "Hidden, concealed objects"]	Things that jutted out — both physical (bastions) and symbolic (arguments)	The text shows that Renaissance English used 'salient' 'for what jutted out — a bastion, a point, an argument' — showing both physical and symbolic projection.	2025-10-27 14:08:23.765029-04	2025-10-27 14:08:23.765029-04
181	56	17	How did early modernity transform 'salient'?	["The physical leap became a mental leap — prominence became cognitive", "It became purely about physical buildings", "It lost all meaning", "It became a synonym for 'hidden'"]	The physical leap became a mental leap — prominence became cognitive	The text states that 'the leap turned inward' and 'Thinkers called an idea 'salient' when it sprang to the mind — prominence became cognition.'	2025-10-27 14:08:23.765584-04	2025-10-27 14:08:23.765584-04
182	56	19	What happened to 'salient' in the industrial and analytic age?	["It stopped being about physical motion but still marked what stood out in data and arguments", "It became only about physical movement", "It completely disappeared", "It meant the opposite — being hidden or obscure"]	It stopped being about physical motion but still marked what stood out in data and arguments	The text states that 'Salient had stopped moving; he now marked data, facts, arguments' showing it stopped being physical while still marking prominence, 'but within it still pulsed the old Latin spring.'	2025-10-27 14:08:23.766071-04	2025-10-27 14:08:23.766071-04
183	56	20-21	How does 'salient' function in the age of cognition and code?	["It became measurable and quantifiable — attention and visibility are now mapped and algorithmically detected", "It became purely aesthetic with no function", "It lost all connection to prominence", "It refers only to physical buildings"]	It became measurable and quantifiable — attention and visibility are now mapped and algorithmically detected	The text explains that 'Attention itself became measurable—visibility quantified' and shows how 'Psychologists mapped what the eye notices first; engineers taught algorithms to mimic the leap' — making salience measurable and algorithmic.	2025-10-27 14:08:23.766592-04	2025-10-27 14:08:23.766592-04
184	83	1	What was the original Latin meaning of 'omittere'?	["To include everything", "To let go deliberately", "To be careless", "To be random"]	To let go deliberately	The text explicitly states that 'omittere' meant 'to let go' and emphasizes it was 'deliberate release, intentional abandonment' with examples of scribes and generals making strategic choices.	2025-10-27 14:08:23.767917-04	2025-10-27 14:08:23.767917-04
185	83	12	How did medieval theology transform 'omit'?	["It became a moral sin—failure to act when duty called", "It became only about forgetting things", "It lost all meaning", "It became a positive virtue"]	It became a moral sin—failure to act when duty called	The text states '*Omettre* became a sin of silence—a thing not done when duty called' and 'To omit was to fail the soul, not the sentence.'	2025-10-27 14:08:23.768958-04	2025-10-27 14:08:23.768958-04
186	83	15	How did late medieval bureaucracy transform 'omit'?	["What was a moral sin became a legal liability—omission in records could ruin fortunes", "It became completely insignificant", "It meant the same as in Rome", "It became only about creative writing"]	What was a moral sin became a legal liability—omission in records could ruin fortunes	The text shows 'where what was left out could ruin fortunes. His sin became paperwork' - moving from moral sin to legal bureaucratic risk.	2025-10-27 14:08:23.769586-04	2025-10-27 14:08:23.769586-04
187	83	16	What changed about 'omit' during the Renaissance?	["It became more random", "It became about purposeful selection and focus", "It became purely about forgetting", "It became about including everything"]	It became about purposeful selection and focus	The text states that 'omitting' was 'what you did when you focused on the essential—not random exclusion, but purposeful selection' and gives examples of scholars and writers making focused choices.	2025-10-27 14:08:23.770141-04	2025-10-27 14:08:23.770141-04
188	83	20	How is 'omit' used in modern English?	["It functions across different discourses—neutral in documents, moral in sermons, with ancient phrases like 'sins of omission' surviving as fossils", "It has only one consistent meaning across all contexts", "It disappeared completely", "It means the same thing in all contexts"]	It functions across different discourses—neutral in documents, moral in sermons, with ancient phrases like 'sins of omission' surviving as fossils	The text shows 'Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame.'	2025-10-27 14:08:23.77067-04	2025-10-27 14:08:23.77067-04
228	542	17	What was the original theological meaning of 'ubīque' and what did it describe?	["Everywhere; describing divine presence that filled all places simultaneously", "Nowhere; describing absence", "Somewhere; describing a single location", "Rarely; describing infrequent presence"]	Everywhere; describing divine presence that filled all places simultaneously	The text states that 'ubīque' meant 'everywhere' and describes it as 'God's presence that filled all places simultaneously' naming 'what could not be contained: the being whose location was everywhere and nowhere.'	2025-10-27 14:08:42.111674-04	2025-10-27 14:08:42.111674-04
229	542	19	How did nineteenth-century science transform 'ubiquitous'?	["It became a physical property describing forces and fields distributed everywhere, moving from divine to material", "It became only about individual locations", "It lost all scientific meaning", "It became synonymous with empty space"]	It became a physical property describing forces and fields distributed everywhere, moving from divine to material	The text states that 'What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any' and shows examples like 'The ether was ubiquitous' and 'Electromagnetic waves were ubiquitous.'	2025-10-27 14:08:42.112845-04	2025-10-27 14:08:42.112845-04
230	542	20	How did mass media and capitalism transform 'ubiquitous'?	["It moved from divine/physical to commercial—brands, ads, and technologies became ubiquitous as success markers", "It became only about individual ownership", "It lost commercial meaning", "It meant only scarcity"]	It moved from divine/physical to commercial—brands, ads, and technologies became ubiquitous as success markers	The text states that 'He moved from the philosophical to the economic, from the metaphysical to the manufactured' and that 'What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.'	2025-10-27 14:08:42.114191-04	2025-10-27 14:08:42.114191-04
231	542	21	How does 'ubiquitous' function in the digital age?	["It describes the digital network/platform that's become the medium we breathe—ubiquity as accomplished fact", "It means rare and hard to access", "It has no digital meaning", "It refers only to analog technology"]	It describes the digital network/platform that's become the medium we breathe—ubiquity as accomplished fact	The text states that 'he is the air itself: the network that connects everyone, the platform that spans all spaces' and that 'His original mystery has been replaced by his accomplished fact'—showing ubiquitous presence is now literal reality.	2025-10-27 14:08:42.114914-04	2025-10-27 14:08:42.114914-04
189	70	1	What was the original Roman meaning of 'perfungī'?	["To do through completely, with endurance as a virtue", "To perform with great emotional feeling", "To do something halfway or partially", "To avoid doing any work"]	To do through completely, with endurance as a virtue	The text states 'perfungī' meant 'to do through' and emphasizes 'He lived in the world of completion, not care' where 'His virtue was endurance, not tenderness.'	2025-10-27 14:08:23.771726-04	2025-10-27 14:08:23.771726-04
190	70	12	How did the medieval church transform 'perfunctorius'?	["It began to describe habit-driven prayer where form was right but heart was missing", "It became about full emotional engagement in prayer", "It lost all meaning", "It became only about military duties"]	It began to describe habit-driven prayer where form was right but heart was missing	The text shows '*Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing' and 'He was no longer a soldier—he was a monk murmuring words he no longer felt.'	2025-10-27 14:08:23.772296-04	2025-10-27 14:08:23.772296-04
191	70	16	What happened to 'perfunctory' during the Renaissance and Reformation?	["It became a negative term, a warning about hollow deeds without feeling", "It became a positive term for efficiency", "It was completely forgotten", "It meant the same as it did in Rome"]	It became a negative term, a warning about hollow deeds without feeling	The text states 'Renaissance writers turned him into a warning: the worker of hollow deeds' and 'The Reformation made him blush—the new world wanted feeling, and he had only form.'	2025-10-27 14:08:23.772845-04	2025-10-27 14:08:23.772845-04
192	70	19	How did the industrial revolution transform 'perfunctory'?	["It became the rhythm of repetition—mechanical work done well but empty of pride or meaning", "It became about inspired, creative labor", "It disappeared from use", "It became synonymous with excellence"]	It became the rhythm of repetition—mechanical work done well but empty of pride or meaning	The text shows 'Every lever pulled, every stamp struck—done through, done well, done empty' and 'The virtue of completion returned, but without pride. He had become the rhythm of repetition.'	2025-10-27 14:08:23.77337-04	2025-10-27 14:08:23.77337-04
193	70	21	How is 'perfunctory' manifested in the digital age?	["In automated communication where the Roman discipline of completion survives but the soul is missing", "In highly personalized, heartfelt digital interactions", "In completely abandoned work", "In artistic and creative digital expression"]	In automated communication where the Roman discipline of completion survives but the soul is missing	The text shows 'he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing.'	2025-10-27 14:08:23.7739-04	2025-10-27 14:08:23.7739-04
194	187	1	What was the original Latin meaning of 'verisimilis'?	["The truth itself", "Like the truth or resembling truth", "Completely false", "Random appearance"]	Like the truth or resembling truth	The text explicitly states that 'verisimilis' meant 'like the truth' and emphasizes it was 'the appearance of truth, the semblance of reality' with examples of actors and orators creating resemblance.	2025-10-27 14:08:23.774968-04	2025-10-27 14:08:23.774968-04
195	187	14	How did medieval theologians transform 'verisimilar'?	["They made it about divine revelation", "They made it about human reasoning that resembled divine wisdom", "They made it purely about falsehood", "They made it about random appearance"]	They made it about human reasoning that resembled divine wisdom	The text states that 'verisimilar doctrine' meant 'teaching that looked like truth—not divine revelation, but human reasoning that resembled divine wisdom.'	2025-10-27 14:08:23.776512-04	2025-10-27 14:08:23.776512-04
196	187	17	How did verisimilitude function in 17th century English literature?	["It became the measure of art—critics and novelists used it to create convincing, lifelike worlds in plays and novels", "It became completely irrelevant to art", "It became only about divine revelation", "It became synonymous with absolute truth"]	It became the measure of art—critics and novelists used it to create convincing, lifelike worlds in plays and novels	The text shows 'Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.'	2025-10-27 14:08:23.777133-04	2025-10-27 14:08:23.777133-04
197	187	19	How did 19th century realists transform verisimilitude?	["They made it almost scientific, demanding research and observation to capture the texture of lived life", "They abandoned it completely", "They made it purely about fantasy", "They made it irrelevant to literature"]	They made it almost scientific, demanding research and observation to capture the texture of lived life	The text shows 'Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader.'	2025-10-27 14:08:23.777638-04	2025-10-27 14:08:23.777638-04
198	187	20	How did verisimilitude function in 20th century contexts?	["In courtrooms as forensic verisimilitude fitting stories to evidence, and in cinema as CGI spectacle—raising ethical questions about trustworthiness", "Only in ancient religious texts", "Completely disappeared", "Only meant literal truth"]	In courtrooms as forensic verisimilitude fitting stories to evidence, and in cinema as CGI spectacle—raising ethical questions about trustworthiness	The text shows 'In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible...' and 'Philosophers questioned her ethics—could a lie made lifelike be trusted?'	2025-10-27 14:08:23.778091-04	2025-10-27 14:08:23.778091-04
199	187	21	How does verisimilitude function in the 21st century digital age?	["As a technology—algorithms and interfaces that engineer the feeling of truth without arguing for it", "It has completely disappeared", "Only in books and literature", "As a synonym for absolute truth"]	As a technology—algorithms and interfaces that engineer the feeling of truth without arguing for it	The text shows 'She's become a technology: algorithms that predict believability, interfaces that feel intuitive because they mimic the real. She no longer argues for truth—she engineers its feeling.'	2025-10-27 14:08:23.778557-04	2025-10-27 14:08:23.778557-04
\.


--
-- Data for Name: timeline_event_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.timeline_event_tags (event_id, tag_id) FROM stdin;
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (id, name, description, silk_cost, image_url) FROM stdin;
\.


--
-- Data for Name: user_floor_boss_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_floor_boss_attempts (id, user_id, floor_id, scenarios_presented, user_responses, correct_count, total_scenarios, success, silk_earned, attempted_at, completed_at) FROM stdin;
\.


--
-- Data for Name: user_map_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_map_progress (id, user_id, map_id, current_floor, current_room, floors_completed, total_silk_spent, total_silk_earned, created_at, updated_at) FROM stdin;
1	5	3	2	1	0	50	0	2025-10-24 20:07:38.652694-04	2025-10-28 03:52:27.354773-04
\.


--
-- Data for Name: user_quiz_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_quiz_progress (id, user_id, word_id, current_level, max_level_reached, health_remaining, silk_earned, completed_at, started_at, updated_at) FROM stdin;
21	5	496	3	3	5	30	\N	2025-10-27 02:58:55.899273-04	2025-10-27 02:59:22.773548-04
6	1	83	1	1	5	0	\N	2025-10-21 13:04:28.14907-04	2025-10-21 13:04:28.14907-04
19	5	542	5	5	2	75	2025-10-27 10:27:56.368041-04	2025-10-27 02:55:05.571954-04	2025-10-27 10:27:56.368041-04
8	1	187	5	5	5	60	\N	2025-10-21 14:24:03.049701-04	2025-10-22 17:34:28.008282-04
5	1	70	5	5	1	50	\N	2025-10-21 03:46:32.010511-04	2025-10-22 17:35:23.288171-04
10	5	187	1	1	5	0	\N	2025-10-22 18:36:48.870817-04	2025-10-22 18:36:48.870817-04
16	5	13	5	5	4	85	2025-10-27 19:31:12.114419-04	2025-10-22 19:49:51.134981-04	2025-10-27 19:31:12.114419-04
13	5	70	5	5	5	60	\N	2025-10-22 18:36:56.730861-04	2025-10-22 20:02:58.37706-04
14	5	27	5	6	4	85	2025-10-25 17:36:24.549167-04	2025-10-22 18:37:17.917411-04	2025-10-28 04:04:13.238613-04
17	5	1	5	6	5	50	2025-10-22 23:03:06.729223-04	2025-10-22 19:49:54.099872-04	2025-10-28 04:04:13.248585-04
12	5	56	5	6	4	85	2025-10-22 23:09:45.664685-04	2025-10-22 18:36:53.879964-04	2025-10-28 04:04:13.249424-04
15	5	83	5	5	5	60	\N	2025-10-22 19:49:36.499286-04	2025-10-22 20:05:34.017178-04
28	10	542	3	3	5	30	\N	2025-10-28 04:18:57.93702-04	2025-10-28 04:20:36.115253-04
18	5	42	5	5	5	60	\N	2025-10-25 12:52:05.888072-04	2025-10-25 12:53:35.188646-04
\.


--
-- Data for Name: user_room_unlocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_room_unlocks (id, user_id, room_id, unlocked_at, silk_spent, silk_earned, completed_at) FROM stdin;
27	5	121	2025-10-24 17:36:57.50218-04	0	0	2025-10-25 18:20:26.678547-04
36	5	123	2025-10-24 20:07:38.652694-04	25	0	2025-10-25 18:20:26.678547-04
37	5	125	2025-10-27 02:50:04.323592-04	25	0	\N
39	8	122	2025-10-27 19:10:15.85524-04	0	0	\N
38	5	122	2025-10-27 19:10:15.849182-04	0	0	2025-10-27 19:31:12.129601-04
40	5	129	2025-10-28 01:15:23.950221-04	0	0	2025-10-28 01:15:23.96772-04
41	5	130	2025-10-28 03:52:27.361011-04	0	0	\N
42	5	138	2025-10-28 03:52:27.363245-04	0	0	2025-10-28 03:52:27.363245-04
44	8	121	2025-10-28 04:06:10.065053-04	0	0	\N
45	10	121	2025-10-28 04:06:10.067487-04	0	0	\N
\.


--
-- Data for Name: user_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_stats (id, user_id, silk_balance, words_mastered, quizzes_completed, total_health_lost, created_at, updated_at) FROM stdin;
1	1	0	0	0	4	2025-10-21 01:36:23.953417-04	2025-10-21 03:50:48.519682-04
2	5	325	1	4	6	2025-10-22 18:36:48.913747-04	2025-10-28 00:21:07.174857-04
3	10	0	0	0	0	2025-10-28 04:18:57.949963-04	2025-10-28 04:18:57.949963-04
\.


--
-- Data for Name: user_story_study_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_story_study_attempts (id, user_id, word_id, question_id, user_answer, is_correct, attempted_at) FROM stdin;
33	5	56	178	Leaping or springing forth physically	t	2025-10-27 15:33:39.613753-04
34	5	56	179	It connected physical motion to visibility and projection in military/architectural contexts	t	2025-10-27 15:33:59.796425-04
35	5	56	180	Things that jutted out — both physical (bastions) and symbolic (arguments)	t	2025-10-27 15:34:22.182665-04
36	5	56	181	The physical leap became a mental leap — prominence became cognitive	t	2025-10-27 15:34:30.931533-04
37	5	13	167	To stick in or cling to physically; used by philosophers to describe properties within matter	t	2025-10-27 19:21:23.785276-04
38	5	13	168	They used it to describe qualities that could never be separated from their substance (virtue in soul, whiteness in snow)	t	2025-10-27 19:22:22.335693-04
39	5	13	169	It moved from metaphysics to politics, describing rights and dignity as qualities that belonged naturally to humans	t	2025-10-27 19:22:50.241312-04
40	5	13	170	To describe structural properties (bias in data, stability in molecules) where the logic of 'belonging within' endures	t	2025-10-27 19:24:12.258344-04
\.


--
-- Data for Name: user_story_study_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_story_study_progress (id, user_id, word_id, story_completed, first_completion_at, last_studied_at, times_studied, total_silk_earned, created_at, updated_at) FROM stdin;
1	5	1	t	2025-10-24 19:12:50.727813-04	2025-10-25 17:51:54.667342-04	6	15	2025-10-24 19:12:50.727813-04	2025-10-25 17:51:54.667342-04
2	5	27	t	2025-10-25 12:00:58.38397-04	2025-10-27 02:49:48.124693-04	4	15	2025-10-25 12:00:58.38397-04	2025-10-27 02:49:48.124693-04
3	5	56	t	2025-10-27 02:51:32.683574-04	2025-10-27 15:34:32.428623-04	2	15	2025-10-27 02:51:32.683574-04	2025-10-27 15:34:32.428623-04
4	5	13	t	2025-10-27 19:24:14.732698-04	2025-10-27 19:24:14.732698-04	1	10	2025-10-27 19:24:14.732698-04	2025-10-27 19:24:14.732698-04
\.


--
-- Data for Name: user_word_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_word_definitions (id, user_id, word_id, initial_definition, created_at, updated_at) FROM stdin;
3	5	1	obstruct	2025-10-24 17:52:58.089649-04	2025-10-25 18:14:44.648257-04
29	5	27	stick together	2025-10-24 20:08:16.076359-04	2025-10-27 02:49:09.122176-04
40	5	56	jutting out in conceptual significance	2025-10-27 02:50:22.564254-04	2025-10-27 15:33:28.884527-04
47	5	13	inherent	2025-10-27 19:17:08.623303-04	2025-10-27 19:17:08.623303-04
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, silk_balance, health_points, last_health_reset, words_learned, words_mastered, total_silk_earned, is_admin, max_health_points, avatar_config) FROM stdin;
5	Matthew	$2b$10$jjJLdDVjegLI2yzpq855XOFxKEpY0TNW675rytjW6l9yNle94ehsm	305	5	2025-10-28 00:00:00.304512	4	3	245	t	3	{"body": "hornet", "mask": "crystal", "wings": "crystal", "weapon": "spell", "effects": ["glow"], "accentColor": "#00d4aa", "primaryColor": "#ffffff", "secondaryColor": "#2d2d44"}
10	Maidiu	$2b$10$Ool30VDbR6RRFUOYIpvbbuiGbl9xuIkeQGPI1Pn8R6tVqifa3zemS	0	3	2025-10-28 04:05:49.118633	0	0	0	f	3	{"body": "hornet", "mask": "hornet", "wings": "silk", "weapon": "needle", "effects": ["sparkle"], "accentColor": "#ff6b6b", "primaryColor": "#2d1b2d", "secondaryColor": "#4a2c4a"}
8	Tom	$2b$10$9txU.FuK6osiyOPNRgZm/ObGtlEnEduYrExRSvcRsL6RCKsJTvVzG	0	3	2025-10-27 19:08:59.291042	0	0	0	f	3	{"body": "hornet", "mask": "hornet", "wings": "silk", "weapon": "needle", "effects": ["sparkle"], "accentColor": "#ff6b6b", "primaryColor": "#2d1b2d", "secondaryColor": "#4a2c4a"}
\.


--
-- Data for Name: vocab_domain_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vocab_domain_links (vocab_id, domain_id) FROM stdin;
1	1
1	2
1	3
1	6
1	5
\.


--
-- Data for Name: vocab_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vocab_entries (id, word, part_of_speech, modern_definition, usage_example, synonyms, antonyms, collocations, french_equivalent, russian_equivalent, cefr_level, pronunciation, is_mastered, date_added, story_text, contrastive_opening, structural_analysis, common_collocations, metadata, definitions, variant_forms, semantic_field, english_synonyms, english_antonyms, french_synonyms, french_root_cognates, russian_synonyms, russian_root_cognates, common_phrases, story_intro, learning_status) FROM stdin;
2	obstruction	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.70517	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
3	delay	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.709657	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
4	resistance	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.711225	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
5	inhibition	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.713117	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
6	assist	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.71461	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
7	facilitate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.715808	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
8	enable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.716714	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
9	promote	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.71758	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
10	advance	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.718595	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
11	impediment	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.719532	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
12	expedite	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.720358	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
14	intrinsic	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.736412	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
15	innate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.737572	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
16	essential	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.738688	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
17	built-in	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.73979	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
18	fundamental	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.740861	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
19	native	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.742202	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
20	external	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.744946	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
21	acquired	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.745702	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
22	extrinsic	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.746441	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
23	adventitious	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.747157	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
24	inherit	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.747816	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
28	unified	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.758499	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
29	connected	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.762853	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
30	integrated	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.764119	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
31	consistent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.765309	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
32	harmonious	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.766408	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
33	fragmented	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.767429	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
34	disjointed	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.768219	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
35	dispersed	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.768955	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
36	incoherent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.769729	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
37	scattered	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.770456	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
38	disconnected	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.77121	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
26	cohere	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.749924	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
40	cohesion	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.772617	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
25	adhere	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.749173	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
528	credible	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.716865	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
529	believable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.722982	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
530	reasonable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.724315	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
531	convincing	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.725463	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
532	persuasive	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.726474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
533	specious	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.728486	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
534	implausible	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.729713	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
535	incredible	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.730496	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
536	unbelievable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.73136	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
537	absurd	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.732176	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
538	ridiculous	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.73314	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
539	applaud	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.734287	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
540	plaudit	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.735267	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
541	applause	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.736216	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
1	impede	verb	to slow or block progress, movement, or development.	Heavy traffic impeded our progress to the airport.	{obstruction,delay,resistance,inhibition}	{assist,facilitate,enable,promote,advance}	{}	entraver — often used for physical or bureaucratic obstruction.	препятствовать (prepyatstvovat’) — to hinder or stand in the way.	C1	\N	f	2025-10-20 22:04:31.62949	\N	\N	A word born of the body’s weight now moves through systems. Its journey from fettered feet to clogged bureaucracy traces the civilization’s shift from moral to mechanical order.	{"impede progress — to slow development or advancement (bureaucratic, academic)","impede access — to make entry or use difficult (rights, equity, logistics)","impede justice — to obstruct or delay legal process (legal idiom)"}	{}	{"primary": "To obstruct or delay the movement or progress of something.", "tertiary": "Figurative: to place barriers in the path of advancement or success.", "secondary": "To hinder or block the functioning or development of a process or person."}	{impediment,impeded,impeding}	{obstruction,delay,resistance,inhibition}	{}	{}	{entraver,bloquer,ralentir}	{"pied — foot"}	{мешать,затруднять,препятствовать}	{"препятствие — obstacle"}	{"impede progress — bureaucratic and technical usage.","impede justice — legal idiom retaining a moral echo.","impede access — rights and equity discourse."}	Impede walks with a quiet weight. He’s the slow hand on a turning wheel, the tangle in a runner’s feet. He isn’t cruel; he just holds things where they are. You meet him in paperwork, in hesitation, in the long breath before action. He doesn’t destroy. He delays.	unmastered
43	haphazard	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.782991	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
44	indiscriminate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.784134	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
45	unfocused	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.785162	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
46	broad-brush	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.786376	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
47	random	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.787529	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
48	targeted	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.788713	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
49	systematic	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.78943	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
50	methodical	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.790116	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
51	precise	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.790857	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
52	focused	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.791627	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
53	shotgun	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.792428	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
54	scatter	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.793349	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
55	aimless	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.80593	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
543	omnipresent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.745817	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
63	obscure	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.822284	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
544	pervasive	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.746979	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
57	prominent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.815294	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
58	notable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.816571	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
59	striking	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.817718	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
60	conspicuous	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.818872	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
61	remarkable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.820042	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
62	outstanding	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.821173	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
545	everywhere	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.748134	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
64	inconspicuous	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.823093	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
65	hidden	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.823859	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
66	minor	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.824574	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
67	salience	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.825431	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
68	saliently	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.826267	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
69	resilient	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.827069	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
71	cursory	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.836264	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
72	mechanical	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.837361	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
73	superficial	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.83836	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
74	indifferent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.839426	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
75	unthinking	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.840388	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
76	thorough	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.841436	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
77	careful	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.842253	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
78	deliberate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.843126	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
79	attentive	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.843914	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
80	conscientious	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.844677	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
187	verisimilitude	noun	the appearance or quality of being true or real; the quality of seeming to be true.	The novel's verisimilitude made readers believe the events had actually occurred.	{plausibility,believability,realism,authenticity,credibility}	{implausibility,incredibility,unreality,falseness}	{}	vraisemblance — the appearance of truth; used in literature and philosophy.	правдоподобие (pravdopodobie) — truthlikeness, plausibility.	C2	\N	f	2025-10-21 14:12:26.362174	\N	\N	Verisimilitude traces the journey from philosophical category to aesthetic principle to technological standard. Born in rhetoric's gray zone between truth and persuasion, she became the measure by which we judge what feels real—proof that likeness can be as powerful as truth itself.	{"verisimilitude in fiction — believability in storytelling (literary criticism)","lack verisimilitude — fail to seem realistic or plausible (critique)","lend verisimilitude — add realistic detail to enhance believability (craft)"}	{}	{"primary": "The appearance or semblance of truth; the quality of appearing to be true or real.", "tertiary": "In philosophy and law: the quality of being probable or likely based on available evidence.", "secondary": "In literature and art: lifelike quality that makes fiction believable."}	{verisimilar}	{truth,appearance,believability,realism,probability}	{}	{}	{vraisemblance,plausibilité,crédibilité}	{"vrai — true","semblable — similar"}	{правдоподобие,достоверность,вероятность}	{"правда — truth","подобный — similar"}	{"verisimilitude in fiction — the art of believable storytelling.","lack verisimilitude — the failure to convince or feel real.","lend verisimilitude — to add detail that creates belief."}	Verisimilitude wears the mask of truth without claiming to be it. She moves between the real and the crafted, making lies feel lived and fictions feel found. She isn't honesty—she's its shadow, its twin. You meet her in novels that breathe, in courtroom arguments that persuade, in designs that feel inevitable. She doesn't promise truth. She promises its likeness.	unmastered
546	universal	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.749363	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
547	commonplace	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.750673	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
548	rare	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.752131	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
549	scarce	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.753013	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
550	uncommon	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.753803	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
551	unusual	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.754913	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
552	absent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.756155	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
553	ubiquity	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.759278	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
81	function	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.845486	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
82	perform	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.846292	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
84	exclude	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.857018	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
85	leave out	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.85808	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
86	skip	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.859662	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
87	neglect	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.861504	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
88	ignore	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.86254	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
89	include	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.863554	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
90	retain	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.864263	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
91	insert	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.864985	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
554	ubiquitously	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.760536	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
92	add	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.865678	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
93	delete	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-20 22:04:31.866368	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
196	falseness	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.374276	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
197	verify	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.375546	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
198	similar	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.376358	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
457	pall	noun, verb	(noun) a heavy, dark cloth covering; a gloomy atmosphere. (verb) to become dull or less interesting.	A pall of smoke hung over the city. The excitement began to pall after the third hour.	{shroud,cloud,gloom,melancholy,envelope}	{brightness,cheer,joy,lightness}	{}	voile — literally 'veil,' figuratively a covering or obscuring element.	покров (pokrov) — a covering or shroud, often somber.	C1	\N	f	2025-10-25 18:31:27.455683	\N	\N	Pall moved from luxury cloth to funeral shroud to emotional atmosphere. It's the story of covering: first bodies, then feelings, then energy itself.	{"pall of smoke — thick, heavy smoke covering an area (descriptive writing)","cast a pall over — create a gloomy atmosphere (figurative, metaphorical)","pall on — become tiresome or less appealing (verb usage, informal)"}	{}	{"primary": "A heavy, dark cloth used to cover something, especially in death or mourning.", "tertiary": "(verb) To become less interesting or lose appeal; to grow wearisome.", "secondary": "A depressing or gloomy atmosphere that seems to hang over something."}	{palled,palling}	{covering,gloom,darkness,mourning,weariness}	{}	{}	{voile,tristesse,mélancolie}	{"pâle — pale"}	{покров,пелена,мрак}	{"бледный — pale"}	{"pall of smoke — thick, dark smoke covering an area.","cast a pall over — create a gloomy or depressing atmosphere.","pall on someone — become tiresome or less interesting to them."}	Pall is the gentle suffocation of things. He's the cloth that covers the coffin, the cloud that dims the sun. He doesn't attack; he settles. You feel his weight in tired hours and grey mornings. He's patient in his work—the slow draining of light, the gradual stilling of sound. He makes quiet spaces where energy once was.	unmastered
199	simulate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.377093	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
200	versimilar	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.377857	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
458	shroud	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.456588	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
188	plausibility	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.362997	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
189	believability	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.365508	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
190	realism	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.367003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
191	authenticity	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.369436	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
192	credibility	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.370583	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
193	implausibility	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.371766	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
194	incredibility	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.372604	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
195	unreality	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-21 14:12:26.373396	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
459	cloud	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.458181	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
446	confirm	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.280146	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
447	certify	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.305319	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
448	validate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.320696	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
449	affirm	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.337773	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
450	deny	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.356323	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
451	refute	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.362406	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
452	dispute	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.366335	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
453	contradict	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.384763	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
454	testament	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.389232	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
444	testify	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.268562	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
456	attestation	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.392113	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
460	gloom	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.459522	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
461	melancholy	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.460723	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
462	envelope	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.461859	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
463	brightness	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.462946	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
42	scattershot	adjective	lacking focus or organization; covering many things in a random or haphazard way.	His scattershot approach to problem-solving wasted time and resources.	{haphazard,indiscriminate,unfocused,broad-brush,random}	{targeted,systematic,methodical,precise,focused}	{}	désordonné — disorganized; 'à la volée' captures the sense of randomness.	беспорядочный (besporyadochnyy) — chaotic, lacking order.	C1	\N	f	2025-10-20 22:04:31.78207	\N	\N	‘Scattershot’ marks the moralization of precision. What began as a hunter’s pattern of spread became a culture’s anxiety about control and coherence.	{"scattershot approach — unfocused or uncoordinated method (management, policy)","scattershot strategy — diffuse plan lacking prioritization (business, politics)","scattershot criticism — broad, indiscriminate attack (journalism, debate)"}	{}	{"primary": "Covering a wide area or range without clear focus or direction.", "tertiary": "Figurative: attempting too much or acting without strategic aim.", "secondary": "Random or haphazard; lacking method or precision."}	{}	{randomness,diffusion,"lack of focus",breadth,chaos}	{}	{}	{désordonné,épars,aléatoire}	{disperser,tir,éparpiller}	{разбросанный,хаотичный,беспорядочный}	{"разброс — scatter"}	{"scattershot approach — effort without aim.","scattershot policy — governance without focus.","scattershot criticism — wide but shallow attack."}	Scattershot lives in the moment before aim. He bursts outward—bright, loud, everywhere at once. He’s energy without a center, ambition before direction. Some call him reckless; others, free. He doesn’t choose a single path—he takes them all, and lets the world decide what lands.	unmastered
464	cheer	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.463732	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
465	joy	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.4646	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
466	lightness	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.465533	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
467	appal	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.466413	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
468	pale	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.467787	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
472	ungainly	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.505347	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
470	clumsy	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.500452	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
471	awkward	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.502625	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
70	perfunctory	adjective	done quickly and without real interest, care, or effort.	He gave a perfunctory nod before leaving the room.	{cursory,mechanical,superficial,indifferent,unthinking}	{thorough,careful,deliberate,attentive,conscientious}	{}	superficiel — lacking depth; 'mécanique' for mechanical sense.	поверхностный (poverkhnostnyy) — superficial, lacking depth or sincerity.	C2	\N	f	2025-10-20 22:04:31.835628	\N	\N	‘Perfunctory’ charts the collapse of duty into disaffection. Born in Rome’s ethic of steadiness, he was remade by religion into guilt, and by industry into automation—a mirror of work emptied of its will.	{"perfunctory nod — minimal acknowledgment (social cue)","perfunctory smile — forced or insincere expression (emotional detachment)","perfunctory task — routine action done without care (workplace idiom)"}	{}	{"primary": "Done quickly and without real care or interest; mechanical.", "tertiary": "Indifferent or apathetic in manner or attitude.", "secondary": "Performed merely as a duty or routine; superficial."}	{perfunctorily,perfunctoriness}	{carelessness,"mechanical action",habit,routine,insincerity}	{}	{}	{superficiel,mécanique}	{fonction,exécution}	{поверхностный,формальный,механический}	{}	{"perfunctory nod — motion without meaning.","perfunctory smile — performance without warmth.","perfunctory ritual — habit without heart."}	Perfunctory walks among us like someone still doing their job long after the reason has gone. He smiles when he’s supposed to, nods when he must, checks the box, moves on. He’s not cruel—just tired. You’ve met him in a rushed 'thanks,' a dry 'sorry,' a promise said without weight. That’s who he is now. But he wasn’t always this way.	unmastered
473	clodding	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.506646	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
474	plodding	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.508266	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
475	graceful	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.509406	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
476	agile	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.510139	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
477	nimble	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.510876	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
478	elegant	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.514482	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
479	swift	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.515246	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
480	lumber	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.516307	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
486	dart	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.551969	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
487	dash	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.553569	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
489	amble	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.556363	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
490	saunter	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.558395	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
491	stroll	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.561337	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
492	linger	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.562611	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
488	scuttle	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.555031	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
484	hurry	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.54554	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
485	rush	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.548921	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
83	omit	verb	to leave out or exclude intentionally or accidentally.	He omitted the crucial detail from his report.	{exclude,"leave out",skip,neglect,ignore}	{include,retain,insert,add}	{}	omettre — neutral register; also means 'to skip' or 'neglect'.	опустить (opustit’) — to omit or leave out; also 'to lower'.	B2	\N	f	2025-10-20 22:04:31.856376	\N	\N	Omit tells the story of absence acquiring meaning. He begins as restraint, becomes sin, turns bureaucratic, and ends editorial—proof that even nothingness, named often enough, becomes an act.	{"sin of omission — failure to act when morally required (theological phrase)","lie of omission — misleading silence (moral idiom)","errors and omissions — legal formula (contracts, insurance)","omit from record — exclusion from documentation (bureaucratic)","by omission — framing absence as shaping meaning (rhetorical use)"}	{}	{"primary": "To leave out or fail to include.", "tertiary": "To exclude intentionally or accidentally from a record, statement, or act.", "secondary": "To neglect to do or say something that should be done."}	{omitted,omitting,omission}	{absence,exclusion,neglect,editing}	{}	{}	{omettre,négliger}	{commettre,soumettre,permettre}	{опускать,пропускать,упускать}	{}	{"sin of omission — moral failure by inaction.","lie of omission — deception by silence.","errors and omissions — legal safeguard.","omit from record — bureaucratic exclusion.","by omission — rhetorical presence of absence."}	Omit is quiet company. He doesn’t strike; he slips away. He’s the space left where something should have been—the pause, the blank, the line forgotten to be drawn. His power is absence itself: what’s unsent, unsaid, undone. He never lies, yet nothing hides better than he does.	unmastered
497	loyal	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.608596	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
498	faithful	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.611243	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
499	constant	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.613015	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
500	unwavering	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.61769	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
501	resolute	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.619884	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
502	firm	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.621367	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
503	fickle	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.622792	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
504	unreliable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.623755	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
505	wavering	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.624777	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
506	inconstant	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.625694	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
507	unstable	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.626588	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
508	steady	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.627586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
509	stead	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.628645	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
510	stand	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.631704	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
512	explain	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.646223	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
513	clarify	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.647567	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
514	illuminate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.649078	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
515	expound	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.663944	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
516	unfold	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.666907	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
517	explicate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.669817	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
519	confuse	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.676547	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
520	muddle	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.68002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
521	bewilder	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.680973	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
522	complicate	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.681866	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
523	lucid	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.682804	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
524	lucidity	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.683797	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
525	elucidation	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.684693	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
526	translucent	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	f	2025-10-25 18:31:27.685619	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	unmastered
496	steadfast	adjective	resolutely unwavering in purpose, loyalty, or faith; firmly fixed in place.	She remained steadfast in her commitment to justice.	{loyal,faithful,constant,unwavering,resolute,firm}	{fickle,unreliable,wavering,inconstant,unstable}	{}	constant — unchanging, loyal; 'fidèle' for faithfulness.	стойкий (stoykiy) — steadfast, firm; 'непоколебимый' for unwavering.	C1	\N	f	2025-10-25 18:31:27.607119	\N	\N	Steadfast moved from physical position to moral constancy to romantic devotion to authentic selfhood. It's the story of standing that became staying, of place that became promise.	{"steadfast friend — loyal and reliable companion (descriptive, character)","steadfast loyalty — unwavering faithfulness to a cause or person (formal writing)","remain steadfast — persist firmly in purpose or belief (formal, moral discourse)"}	{}	{"primary": "Firmly fixed in position or purpose; not likely to change or waver.", "tertiary": "Characterized by unwavering determination or resolve.", "secondary": "Loyal and committed, especially in the face of difficulty or opposition."}	{steadfastly,steadfastness}	{loyalty,constancy,firmness,faithfulness,resolve}	{}	{}	{constant,fidèle,inébranlable}	{stable,constance}	{стойкий,непоколебимый,верный}	{"стоять — to stand"}	{"steadfast friend — loyal and reliable companion who does not waver.","steadfast loyalty — unwavering faithfulness to a cause, person, or principle.","remain steadfast — persist firmly in purpose, belief, or commitment despite challenges."}	Steadfast is the unmovable heart. He's the oath that does not break, the belief that weathers storm. He doesn't shout his loyalty; he simply stands. You find him in promises kept, in causes held when others fade. He's not stubborn but true—the friend who stays when everyone else goes, the faith that endures when doubt walks in. His power is constancy. His virtue is time.	unmastered
511	elucidate	verb	to make clear and explain; to shed light on something that is obscure or difficult to understand.	The professor elucidated the complex theory in terms that everyone could understand.	{explain,clarify,illuminate,expound,unfold,explicate}	{obscure,confuse,muddle,bewilder,complicate}	{}	élucider — same meaning; formal, academic register.	объяснить (obyasnit') — to explain or clarify; 'разъяснить' for detailed clarification.	C2	\N	f	2025-10-25 18:31:27.642254	\N	\N	Elucidate traces the journey from passive brightness to active illumination. Starting as the quality of being clear, it became the act of making clear—from light received to light deliberately cast.	{"elucidate the meaning — explain the significance (academic, formal writing)","elucidate on — provide detailed clarification about (scholarly discourse)","elucidate a concept — make an idea clear through explanation (educational context)"}	{}	{"primary": "To make something clear or easy to understand by explanation.", "tertiary": "To unfold or reveal meaning through systematic explanation.", "secondary": "To provide clarity and illumination on a complex or obscure subject."}	{elucidated,elucidating,elucidation,elucidative}	{explanation,clarity,light,understanding,revelation}	{}	{}	{éclaircir,clarifier,expliquer}	{lucide,luminosité}	{разъяснить,просветить,осветить}	{"свет — light","ясный — clear"}	{"elucidate the meaning — explain significance or interpretation.","elucidate on — provide detailed clarification or expansion.","elucidate a concept — make an idea clear through systematic explanation."}	Elucidate is the breaking of dawn over confused minds. He arrives quietly, bringing light where shadows gathered. He doesn't force understanding; he removes the veil. You find him in patient teachers, in clear arguments, in moments when the complex suddenly yields its secret. His gift is illumination—not the sudden flash but the steady glow that reveals what was always there, waiting to be seen.	unmastered
527	plausible	adjective	seeming reasonable or probable; appearing worthy of belief or acceptance.	Her explanation sounded plausible, but we needed more evidence.	{credible,believable,reasonable,convincing,persuasive,specious}	{implausible,incredible,unbelievable,absurd,ridiculous}	{}	plausible — same meaning; 'vraisemblable' as alternative.	правдоподобный (pravdopodobnyy) — seeming true or believable.	B2	\N	f	2025-10-25 18:31:27.715933	\N	\N	Plausible moved from theatrical applause to philosophical probability to social respectability to persuasive strategy. Her journey tracks the shift from 'worthy of approval' to 'appearing reasonable'—from judgment to appearance.	{"plausible explanation — believable account or reason (general use)","plausible deniability — ability to deny involvement convincingly (legal, political)","sound plausible — appear reasonable upon hearing (conversational)"}	{}	{"primary": "Appearing reasonable or credible; seeming worthy of belief.", "tertiary": "Capable of being applauded or approved as reasonable.", "secondary": "Having the appearance of truth without necessarily being true."}	{plausibility,plausibly}	{believability,credibility,reasonableness,appearance,persuasion}	{}	{}	{vraisemblable,crédible,raisonnable}	{applaudir,applaudissement}	{правдоподобный,убедительный,разумный}	{"аплодировать — to applaud"}	{"plausible explanation — believable account that seems reasonable.","plausible deniability — ability to deny involvement convincingly.","sound plausible — appear reasonable when heard or considered."}	Plausible sits at the threshold of belief. She presents herself as reasonable, dressed in the clothes of acceptability. She doesn't promise truth—only the appearance of it. You meet her in convincing arguments that might be wrong, in stories that could be true, in explanations that feel right even when they're incomplete. Her power is persuasion through seeming, not certainty.	unmastered
443	attest	verb	to provide evidence or proof of something; to bear witness.	The ancient ruins attest to the glory of a long-vanished civilization.	{testify,verify,confirm,certify,validate,affirm}	{deny,refute,dispute,contradict}	{}	attester — formal verification, legal or official confirmation.	свидетельствовать (svidetel'stvovat') — to testify or give evidence.	C1	\N	f	2025-10-25 18:31:27.078469	\N	\N	Attest shows how truth moved from the witness's body to the document's seal. It's the story of presence becoming proof, of the human voice becoming institutional record.	{"attest to — provide evidence of something (formal writing, academic)","attest that — formally declare or certify (legal, official documents)","attest by — verify through specific means or witnesses (legal testimony)"}	{}	{"primary": "To provide clear evidence or proof of something's existence or truth.", "tertiary": "To serve as a witness or testimony to a fact or event.", "secondary": "To declare or certify as true, especially in a formal or official context."}	{attestation,attested,attesting}	{evidence,proof,verification,witness,confirmation}	{}	{}	{témoigner,certifier,confirmer}	{"témoin — witness",testament}	{свидетельствовать,подтверждать,удостоверять}	{"свидетель — witness","засвидетельствовать — to certify"}	{"attest to — provide evidence of something's truth or existence.","attest that — formally declare or certify a statement.","attested by — verified or confirmed through specific means or witnesses."}	Attest holds up the mirror to truth. He's the standing stone that says yes—this happened, this is real, I was there. He speaks with the weight of presence. You find him in courts and archives, in sworn statements and ancient scrolls. He doesn't argue; he simply stands before what he has witnessed and will not look away.	unmastered
469	lumbering	adjective	moving in a slow, heavy, awkward way.	The lumbering bear crashed through the undergrowth.	{clumsy,awkward,ungainly,clodding,plodding}	{graceful,agile,nimble,elegant,swift}	{}	lourd — heavy in movement; 'se déplacer lourdement' for the action.	неуклюжий (neuklyuzhiy) — clumsy or awkward in movement.	B2	\N	f	2025-10-25 18:31:27.499625	\N	\N	Lumbering moved from stored goods to falling timber to moving creatures to industrial machines. It's the story of weight finding motion, of bulk becoming gait.	{"lumbering bear — large animal moving heavily (natural description)","lumbering giant — oversized thing or person moving awkwardly (figurative)","lumbering through — moving heavily through space or effort (narrative writing)"}	{}	{"primary": "Moving in a heavy, ungraceful manner, often with a sense of size or weight.", "tertiary": "Metaphorically, suggesting a process or system that moves slowly and inefficiencies.", "secondary": "Characterized by slow, awkward, or ponderous movement."}	{lumber,lumbered}	{movement,weight,awkwardness,slowness,clumsiness}	{}	{}	{lourd,maladroit,pesant}	{"lombard — Lombard, relating to northern Italian merchants"}	{неуклюжий,тяжёлый,неловкий}	{}	{"lumbering bear — large animal moving heavily through terrain.","lumbering giant — oversized thing moving awkwardly.","lumbering through — moving heavily and deliberately through space."}	Lumbering is what weight looks like when it moves. He's the sound of too much mass in motion—earth shaking, trees falling, things too big for their own feet. He's not evil, just big. You feel him in the thunder of hooves, in the crash of freight. He makes no apology for his size. The world yields before his slow, certain advance.	unmastered
483	scurry	verb, noun	(verb) to move hurriedly with short, quick steps. (noun) a hurried movement or activity.	The mice scurry into their holes when they hear a sound.	{hurry,rush,dart,dash,scuttle}	{amble,saunter,stroll,linger}	{}	se précipiter — to rush or hurry, often with quick, short steps.	суетиться (suetit'sya) — to bustle or hurry about.	B2	\N	f	2025-10-25 18:31:27.544113	\N	\N	Scurry shows how small, urgent movement became the signature gait of everything hunted, busy, or distracted. It's the story of haste made small, of hurry reduced to furtive dash.	{"scurry about — move hurriedly from place to place (descriptive writing)","scurry away — hurry off quickly, often in fear (narrative)","scurry of activity — a flurry of hurried actions (metaphorical noun)"}	{}	{"primary": "To move quickly with short, rapid steps, often suggesting nervousness or urgency.", "tertiary": "(noun) A hurried movement or flurry of activity.", "secondary": "To hurry about busily in a somewhat frantic or disorganized manner."}	{scurried,scurrying}	{movement,haste,urgency,busyness,smallness}	{}	{}	{"se précipiter","se dépêcher",courir}	{}	{суетиться,торопиться,спешить}	{"суета — bustle, fuss"}	{"scurry about — move hurriedly from place to place.","scurry away — hurry off quickly, often in fear or haste.","scurry of activity — a flurry of hurried, busy actions."}	Scurry is motion made small and urgent. He's the dash of tiny feet, the quick panic before flight. He doesn't walk; he scampers. You see him in corners and cracks, in the sudden movement that makes you start. He's not cruel, just quick. His world is hurry—the small hurry of things that must not be caught.	unmastered
56	salient	adjective	most noticeable or important; prominent or striking.	The most salient feature of the proposal was its emphasis on sustainability.	{prominent,notable,striking,conspicuous,remarkable,outstanding}	{obscure,inconspicuous,hidden,minor}	{}	saillant — literally 'leaping out'; used for prominence or protrusion.	выдающийся (vydaiushchiysya) — prominent, remarkable.	C1	\N	f	2025-10-20 22:04:31.814598	\N	\N	‘Salient’ traces the conversion of motion into meaning. Born in the leap of bodies and fountains, it became the figure for prominence in thought—a standing reminder that every idea once sprang from life’s movement.	{"salient feature — most prominent aspect (analysis, design)","salient point — main or central argument (rhetoric)","salient angle — projecting angle in military or architectural use (historical)","most salient — intensifier for central importance (journalism, commentary)"}	{}	{"primary": "Most noticeable or important; standing out prominently.", "tertiary": "Figurative: striking or leaping to attention through force or clarity.", "secondary": "Projecting outward, as in a salient angle or bulge."}	{salience,saliently}	{prominence,emphasis,projection,distinctness,visibility}	{}	{}	{saillant,remarquable}	{"sauter — to leap","ressortir — to stand out"}	{выдающийся,"бросающийся в глаза"}	{"сальто — borrowed from Italian salto (leap)"}	{"salient point — the idea that leaps to mind.","salient feature — what stands out in view or argument.","salient angle — projection toward encounter or risk.","most salient — the peak of prominence."}	Salient is the leap made visible—the instant something crosses from hidden to seen. He’s the flash in the mind, the outcrop on the plain. He doesn’t whisper for attention; he springs toward it. Wherever meaning wants to be found, Salient has already taken a step forward.	unmastered
542	ubiquitous	adjective	present, appearing, or found everywhere; extremely common or widespread.	Smartphones have become ubiquitous in modern life.	{omnipresent,pervasive,everywhere,universal,commonplace}	{rare,scarce,uncommon,unusual,absent}	{}	ubiquitaire — same meaning; 'omniprésent' as more common alternative.	вездесущий (vezdesushchiy) — present everywhere, omnipresent.	C1	\N	f	2025-10-25 18:31:27.745155	\N	\N	Ubiquitous traces the journey from divine attribute to physical property to commercial strategy to digital reality. Starting as the impossible word for divine presence, it became the ordinary word for what literally fills all spaces—from theology to actuality.	{"ubiquitous presence — appearing everywhere (formal, descriptive)","ubiquitous technology — widespread and constantly present tech (contemporary discourse)","seemingly ubiquitous — appearing to be everywhere (emphatic)"}	{}	{"primary": "Present or appearing everywhere at the same time.", "tertiary": "Seeming to be everywhere simultaneously.", "secondary": "Excessively or extremely common or widespread."}	{ubiquity,ubiquitously}	{presence,pervasiveness,omnipresence,universality,commonness}	{}	{}	{omniprésent,répandu,généralisé}	{"partout — everywhere"}	{вездесущий,повсеместный,всепроникающий}	{"везде — everywhere","существовать — to exist"}	{"ubiquitous presence — appearing everywhere simultaneously.","ubiquitous technology — widespread and constantly accessible tech infrastructure.","seemingly ubiquitous — appearing to exist in all places."}	Ubiquitous has learned to be everywhere without ever leaving himself behind. He multiplies without reducing, spreads without thinning. You find him in the repeated logo, in the phrase everyone knows, in the thing that cannot be escaped. He is the opposite of solitude—presence made infinite, identity distributed across all spaces until space itself becomes his name.	unmastered
13	inherent	adjective	existing as a permanent, essential, or characteristic attribute of something.	Risk is inherent in all forms of investment.	{intrinsic,innate,essential,built-in,fundamental,native}	{external,acquired,extrinsic,adventitious}	{}	inhérent — same meaning; formal and philosophical register.	присущий (prisyushchiy) — innate, belonging naturally to.	C1	\N	f	2025-10-20 22:04:31.735708	\N	\N	‘Inherent’ shows how a single image—something clinging within—became the foundation for ideas of essence, morality, and structure. It’s the story of adhesion turned into identity.	{"inherent risk — unavoidable or native to a system (finance, engineering)","inherent value — fundamental or intrinsic worth (philosophy, economics)","inherent right — natural or inborn entitlement (law, ethics)"}	{}	{"primary": "Belonging naturally; existing as an essential part of something.", "tertiary": "Philosophical: existing within a substance rather than derived from something external.", "secondary": "Permanently associated with and inseparable from the subject."}	{inherence,inherently}	{essence,nature,quality,property,identity}	{}	{}	{intrinsèque,"propre à"}	{adhérer,cohérent}	{врождённый,свойственный,присущий}	{}	{"inherent risk — unavoidable or native to the system.","inherent value — philosophical or economic sense of intrinsic worth.","inherent right — moral and political discourse on innate entitlement."}	Inherent is the quiet bond between a thing and what it cannot lose. He’s not loud about it—he simply abides. You find him in the weight of stone, in the pulse of justice, in the curve of instinct. He doesn’t add; he dwells. His power is the stillness of what already belongs.	unmastered
27	cohesive	adjective	forming a united whole; characterized by or causing cohesion.	The team was highly cohesive, working together with remarkable trust.	{unified,connected,integrated,consistent,harmonious}	{fragmented,disjointed,dispersed,incoherent,scattered,disconnected}	{}	cohésif — technical term; more often 'cohérent' in everyday usage.	связный (svyaznyy) — logically or structurally connected.	B2	\N	f	2025-10-20 22:04:31.757824	\N	\N	‘Cohesive’ charts how the language of matter became the language of belonging. What began in glue and grain now holds together minds, stories, and societies.	{"cohesive team — group united by trust or shared purpose (organizational use)","cohesive argument — logically connected reasoning (academic writing)","cohesive device — linguistic element linking parts of a text (linguistics)"}	{}	{"primary": "Forming a united whole; characterized by internal connection or consistency.", "tertiary": "Logical: showing clear connection between parts of a text or argument.", "secondary": "Causing cohesion or sticking together physically or metaphorically."}	{cohesion,cohesively,cohesiveness}	{unity,connection,consistency,adhesion,solidarity}	{}	{}	{cohérent,solidaire}	{adhérent,collant}	{связный,единый,сплочённый}	{"связь — connection"}	{"cohesive team — strength through shared trust.","cohesive argument — reasoning that holds together.","cohesive device — the invisible bridge of language between thoughts."}	Cohesive is the hum beneath harmony—the invisible pull that makes many things one. He moves quietly between fingers clasped in work, between thoughts that fit together cleanly. He’s not loud like unity or proud like strength. He’s the unseen gravity that holds the form intact.	unmastered
\.


--
-- Data for Name: word_relations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.word_relations (id, source_id, target_id, relation_type, note, created_at) FROM stdin;
1	1	5	synonym	\N	2025-10-18 00:40:58.603314-04
2	5	1	synonym	\N	2025-10-18 00:40:58.618092-04
3	1	6	synonym	\N	2025-10-18 00:40:58.619526-04
4	6	1	synonym	\N	2025-10-18 00:40:58.620293-04
5	1	7	synonym	\N	2025-10-18 00:40:58.621794-04
6	7	1	synonym	\N	2025-10-18 00:40:58.622668-04
7	1	8	antonym	\N	2025-10-18 00:40:58.623955-04
8	1	9	antonym	\N	2025-10-18 00:40:58.625255-04
9	1	3	antonym	\N	2025-10-18 00:40:58.62666-04
10	1	11	related	\N	2025-10-18 00:40:58.627815-04
11	1	12	related	\N	2025-10-18 00:40:58.628912-04
12	1	13	related	\N	2025-10-18 00:40:58.630039-04
13	16	17	synonym	\N	2025-10-18 02:50:45.845486-04
14	17	16	synonym	\N	2025-10-18 02:50:45.851044-04
15	16	18	synonym	\N	2025-10-18 02:50:45.852351-04
16	18	16	synonym	\N	2025-10-18 02:50:45.853028-04
17	16	19	synonym	\N	2025-10-18 02:50:45.854515-04
18	19	16	synonym	\N	2025-10-18 02:50:45.85533-04
19	16	20	antonym	\N	2025-10-18 02:50:45.856625-04
20	16	21	antonym	\N	2025-10-18 02:50:45.857917-04
21	16	22	antonym	\N	2025-10-18 02:50:45.859162-04
22	16	23	related	\N	2025-10-18 02:50:45.860322-04
23	16	24	related	\N	2025-10-18 02:50:45.861524-04
24	25	26	synonym	\N	2025-10-18 02:50:45.864003-04
25	26	25	synonym	\N	2025-10-18 02:50:45.864537-04
26	25	27	synonym	\N	2025-10-18 02:50:45.865478-04
27	27	25	synonym	\N	2025-10-18 02:50:45.865945-04
28	25	28	synonym	\N	2025-10-18 02:50:45.866853-04
29	28	25	synonym	\N	2025-10-18 02:50:45.867269-04
30	25	29	antonym	\N	2025-10-18 02:50:45.86847-04
31	25	30	antonym	\N	2025-10-18 02:50:45.86945-04
32	25	31	antonym	\N	2025-10-18 02:50:45.87035-04
33	25	32	related	\N	2025-10-18 02:50:45.871253-04
34	25	33	related	\N	2025-10-18 02:50:45.87209-04
35	34	35	synonym	\N	2025-10-18 02:50:45.873675-04
36	35	34	synonym	\N	2025-10-18 02:50:45.874056-04
37	34	36	synonym	\N	2025-10-18 02:50:45.874879-04
38	36	34	synonym	\N	2025-10-18 02:50:45.875227-04
39	34	37	synonym	\N	2025-10-18 02:50:45.876095-04
40	37	34	synonym	\N	2025-10-18 02:50:45.87655-04
41	34	38	antonym	\N	2025-10-18 02:50:45.877341-04
42	34	39	antonym	\N	2025-10-18 02:50:45.878273-04
43	34	40	antonym	\N	2025-10-18 02:50:45.879193-04
44	34	41	related	\N	2025-10-18 02:50:45.880042-04
45	34	42	related	\N	2025-10-18 02:50:45.880834-04
46	43	44	synonym	\N	2025-10-18 02:50:45.884677-04
47	44	43	synonym	\N	2025-10-18 02:50:45.885109-04
48	43	45	synonym	\N	2025-10-18 02:50:45.888303-04
49	45	43	synonym	\N	2025-10-18 02:50:45.88879-04
50	43	46	synonym	\N	2025-10-18 02:50:45.890065-04
51	46	43	synonym	\N	2025-10-18 02:50:45.890568-04
52	43	47	antonym	\N	2025-10-18 02:50:45.891676-04
53	43	48	antonym	\N	2025-10-18 02:50:45.892691-04
54	43	49	antonym	\N	2025-10-18 02:50:45.893645-04
55	43	50	related	\N	2025-10-18 02:50:45.894622-04
56	43	51	related	\N	2025-10-18 02:50:45.89553-04
57	52	53	synonym	\N	2025-10-18 02:50:45.897113-04
58	53	52	synonym	\N	2025-10-18 02:50:45.897548-04
59	52	54	synonym	\N	2025-10-18 02:50:45.898367-04
60	54	52	synonym	\N	2025-10-18 02:50:45.898739-04
61	52	55	synonym	\N	2025-10-18 02:50:45.899538-04
62	55	52	synonym	\N	2025-10-18 02:50:45.899892-04
63	52	56	antonym	\N	2025-10-18 02:50:45.900678-04
64	52	57	antonym	\N	2025-10-18 02:50:45.901429-04
65	52	58	antonym	\N	2025-10-18 02:50:45.902216-04
66	52	59	related	\N	2025-10-18 02:50:45.903018-04
67	52	60	related	\N	2025-10-18 02:50:45.9039-04
68	11	62	synonym	\N	2025-10-18 02:50:45.905561-04
69	62	11	synonym	\N	2025-10-18 02:50:45.906-04
70	11	63	synonym	\N	2025-10-18 02:50:45.90692-04
71	63	11	synonym	\N	2025-10-18 02:50:45.90735-04
72	11	64	antonym	\N	2025-10-18 02:50:45.908156-04
73	11	65	related	\N	2025-10-18 02:50:45.908919-04
74	66	67	synonym	\N	2025-10-18 02:50:45.91055-04
75	67	66	synonym	\N	2025-10-18 02:50:45.910976-04
76	66	68	synonym	\N	2025-10-18 02:50:45.911937-04
77	68	66	synonym	\N	2025-10-18 02:50:45.912295-04
78	66	69	synonym	\N	2025-10-18 02:50:45.913068-04
79	69	66	synonym	\N	2025-10-18 02:50:45.91339-04
80	66	70	antonym	\N	2025-10-18 02:50:45.914177-04
81	66	71	antonym	\N	2025-10-18 02:50:45.91495-04
82	66	72	antonym	\N	2025-10-18 02:50:45.915793-04
83	66	73	related	\N	2025-10-18 02:50:45.916666-04
84	66	74	related	\N	2025-10-18 02:50:45.917486-04
85	1	3	synonym	\N	2025-10-18 04:21:15.572747-04
86	3	1	synonym	\N	2025-10-18 04:21:15.5944-04
87	1	4	synonym	\N	2025-10-18 04:21:15.59632-04
88	4	1	synonym	\N	2025-10-18 04:21:15.597493-04
93	1	7	antonym	\N	2025-10-18 04:21:15.604036-04
96	1	10	antonym	\N	2025-10-18 04:21:15.607762-04
97	1	11	antonym	\N	2025-10-18 04:21:15.609115-04
100	14	15	synonym	\N	2025-10-18 04:21:15.641196-04
101	15	14	synonym	\N	2025-10-18 04:21:15.641789-04
102	14	16	synonym	\N	2025-10-18 04:21:15.643042-04
103	16	14	synonym	\N	2025-10-18 04:21:15.643585-04
104	14	17	synonym	\N	2025-10-18 04:21:15.644689-04
105	17	14	synonym	\N	2025-10-18 04:21:15.645429-04
106	14	18	synonym	\N	2025-10-18 04:21:15.646633-04
107	18	14	synonym	\N	2025-10-18 04:21:15.647216-04
108	14	19	synonym	\N	2025-10-18 04:21:15.64829-04
109	19	14	synonym	\N	2025-10-18 04:21:15.648761-04
110	14	20	synonym	\N	2025-10-18 04:21:15.649849-04
111	20	14	synonym	\N	2025-10-18 04:21:15.650301-04
112	14	21	antonym	\N	2025-10-18 04:21:15.653119-04
113	14	22	antonym	\N	2025-10-18 04:21:15.654137-04
114	14	23	antonym	\N	2025-10-18 04:21:15.655176-04
115	14	24	antonym	\N	2025-10-18 04:21:15.656715-04
116	14	25	related	\N	2025-10-18 04:21:15.657723-04
117	14	26	related	\N	2025-10-18 04:21:15.658703-04
118	14	27	related	\N	2025-10-18 04:21:15.659672-04
119	28	29	synonym	\N	2025-10-18 04:21:15.674055-04
120	29	28	synonym	\N	2025-10-18 04:21:15.674554-04
121	28	30	synonym	\N	2025-10-18 04:21:15.675635-04
122	30	28	synonym	\N	2025-10-18 04:21:15.676112-04
123	28	31	synonym	\N	2025-10-18 04:21:15.677157-04
124	31	28	synonym	\N	2025-10-18 04:21:15.677588-04
125	28	32	synonym	\N	2025-10-18 04:21:15.678651-04
126	32	28	synonym	\N	2025-10-18 04:21:15.679192-04
127	28	33	synonym	\N	2025-10-18 04:21:15.680309-04
128	33	28	synonym	\N	2025-10-18 04:21:15.680805-04
129	28	34	antonym	\N	2025-10-18 04:21:15.684293-04
130	28	35	antonym	\N	2025-10-18 04:21:15.685493-04
131	28	36	antonym	\N	2025-10-18 04:21:15.686778-04
132	28	37	antonym	\N	2025-10-18 04:21:15.68795-04
133	28	38	antonym	\N	2025-10-18 04:21:15.689103-04
134	28	39	antonym	\N	2025-10-18 04:21:15.690217-04
135	28	27	related	\N	2025-10-18 04:21:15.69138-04
136	28	41	related	\N	2025-10-18 04:21:15.692553-04
137	28	26	related	\N	2025-10-18 04:21:15.693643-04
144	43	47	synonym	\N	2025-10-18 04:21:15.712132-04
145	47	43	synonym	\N	2025-10-18 04:21:15.71271-04
146	43	48	synonym	\N	2025-10-18 04:21:15.713865-04
147	48	43	synonym	\N	2025-10-18 04:21:15.714352-04
149	43	50	antonym	\N	2025-10-18 04:21:15.716378-04
150	43	51	antonym	\N	2025-10-18 04:21:15.717297-04
151	43	52	antonym	\N	2025-10-18 04:21:15.718239-04
152	43	53	antonym	\N	2025-10-18 04:21:15.719211-04
153	43	54	related	\N	2025-10-18 04:21:15.720129-04
154	43	55	related	\N	2025-10-18 04:21:15.721064-04
155	43	56	related	\N	2025-10-18 04:21:15.722033-04
156	57	58	synonym	\N	2025-10-18 04:21:15.737446-04
157	58	57	synonym	\N	2025-10-18 04:21:15.737868-04
158	57	59	synonym	\N	2025-10-18 04:21:15.738733-04
159	59	57	synonym	\N	2025-10-18 04:21:15.739204-04
160	57	60	synonym	\N	2025-10-18 04:21:15.740369-04
161	60	57	synonym	\N	2025-10-18 04:21:15.740881-04
162	57	61	synonym	\N	2025-10-18 04:21:15.741971-04
163	61	57	synonym	\N	2025-10-18 04:21:15.742427-04
164	57	62	synonym	\N	2025-10-18 04:21:15.743612-04
165	62	57	synonym	\N	2025-10-18 04:21:15.744036-04
166	57	63	synonym	\N	2025-10-18 04:21:15.74506-04
167	63	57	synonym	\N	2025-10-18 04:21:15.74556-04
168	57	64	antonym	\N	2025-10-18 04:21:15.746623-04
169	57	65	antonym	\N	2025-10-18 04:21:15.747667-04
170	57	66	antonym	\N	2025-10-18 04:21:15.748636-04
171	57	67	antonym	\N	2025-10-18 04:21:15.74952-04
172	57	68	related	\N	2025-10-18 04:21:15.750516-04
173	57	69	related	\N	2025-10-18 04:21:15.753581-04
174	57	70	related	\N	2025-10-18 04:21:15.756189-04
175	71	72	synonym	\N	2025-10-18 04:21:15.768245-04
176	72	71	synonym	\N	2025-10-18 04:21:15.768703-04
177	71	73	synonym	\N	2025-10-18 04:21:15.769605-04
178	73	71	synonym	\N	2025-10-18 04:21:15.770026-04
179	71	74	synonym	\N	2025-10-18 04:21:15.770867-04
180	74	71	synonym	\N	2025-10-18 04:21:15.771247-04
181	71	75	synonym	\N	2025-10-18 04:21:15.772105-04
182	75	71	synonym	\N	2025-10-18 04:21:15.772528-04
183	71	76	synonym	\N	2025-10-18 04:21:15.773305-04
184	76	71	synonym	\N	2025-10-18 04:21:15.773675-04
185	71	77	antonym	\N	2025-10-18 04:21:15.774538-04
186	71	78	antonym	\N	2025-10-18 04:21:15.775367-04
187	71	79	antonym	\N	2025-10-18 04:21:15.776232-04
188	71	80	antonym	\N	2025-10-18 04:21:15.777143-04
189	71	81	antonym	\N	2025-10-18 04:21:15.778102-04
190	71	82	related	\N	2025-10-18 04:21:15.780246-04
191	71	83	related	\N	2025-10-18 04:21:15.781296-04
192	84	85	synonym	\N	2025-10-18 04:21:15.795357-04
193	85	84	synonym	\N	2025-10-18 04:21:15.795998-04
194	84	86	synonym	\N	2025-10-18 04:21:15.797107-04
195	86	84	synonym	\N	2025-10-18 04:21:15.797663-04
196	84	87	synonym	\N	2025-10-18 04:21:15.798831-04
197	87	84	synonym	\N	2025-10-18 04:21:15.799305-04
198	84	88	synonym	\N	2025-10-18 04:21:15.800359-04
199	88	84	synonym	\N	2025-10-18 04:21:15.800876-04
200	84	89	synonym	\N	2025-10-18 04:21:15.801799-04
201	89	84	synonym	\N	2025-10-18 04:21:15.802255-04
202	84	90	antonym	\N	2025-10-18 04:21:15.803192-04
203	84	91	antonym	\N	2025-10-18 04:21:15.804144-04
204	84	92	antonym	\N	2025-10-18 04:21:15.805073-04
205	84	93	antonym	\N	2025-10-18 04:21:15.806092-04
206	84	94	related	\N	2025-10-18 04:21:15.807003-04
207	1	2	synonym	\N	2025-10-20 22:04:31.706262-04
208	2	1	synonym	\N	2025-10-20 22:04:31.709062-04
215	1	6	antonym	\N	2025-10-20 22:04:31.715267-04
222	13	14	synonym	\N	2025-10-20 22:04:31.736849-04
223	14	13	synonym	\N	2025-10-20 22:04:31.73719-04
224	13	15	synonym	\N	2025-10-20 22:04:31.737987-04
225	15	13	synonym	\N	2025-10-20 22:04:31.738303-04
226	13	16	synonym	\N	2025-10-20 22:04:31.739078-04
227	16	13	synonym	\N	2025-10-20 22:04:31.739433-04
228	13	17	synonym	\N	2025-10-20 22:04:31.740188-04
229	17	13	synonym	\N	2025-10-20 22:04:31.740533-04
230	13	18	synonym	\N	2025-10-20 22:04:31.741382-04
231	18	13	synonym	\N	2025-10-20 22:04:31.741794-04
232	13	19	synonym	\N	2025-10-20 22:04:31.74388-04
233	19	13	synonym	\N	2025-10-20 22:04:31.744542-04
234	13	20	antonym	\N	2025-10-20 22:04:31.745359-04
235	13	21	antonym	\N	2025-10-20 22:04:31.746107-04
236	13	22	antonym	\N	2025-10-20 22:04:31.746831-04
237	13	23	antonym	\N	2025-10-20 22:04:31.747515-04
238	13	24	related	\N	2025-10-20 22:04:31.74875-04
239	13	25	related	\N	2025-10-20 22:04:31.74959-04
240	13	26	related	\N	2025-10-20 22:04:31.750307-04
241	27	28	synonym	\N	2025-10-20 22:04:31.761904-04
242	28	27	synonym	\N	2025-10-20 22:04:31.762423-04
243	27	29	synonym	\N	2025-10-20 22:04:31.763295-04
244	29	27	synonym	\N	2025-10-20 22:04:31.763694-04
245	27	30	synonym	\N	2025-10-20 22:04:31.764615-04
246	30	27	synonym	\N	2025-10-20 22:04:31.764959-04
247	27	31	synonym	\N	2025-10-20 22:04:31.765698-04
248	31	27	synonym	\N	2025-10-20 22:04:31.766056-04
249	27	32	synonym	\N	2025-10-20 22:04:31.76679-04
250	32	27	synonym	\N	2025-10-20 22:04:31.767109-04
251	27	33	antonym	\N	2025-10-20 22:04:31.767824-04
252	27	34	antonym	\N	2025-10-20 22:04:31.76861-04
253	27	35	antonym	\N	2025-10-20 22:04:31.769384-04
254	27	36	antonym	\N	2025-10-20 22:04:31.770116-04
255	27	37	antonym	\N	2025-10-20 22:04:31.770845-04
256	27	38	antonym	\N	2025-10-20 22:04:31.771585-04
257	27	26	related	\N	2025-10-20 22:04:31.772278-04
258	27	40	related	\N	2025-10-20 22:04:31.773009-04
259	27	25	related	\N	2025-10-20 22:04:31.77371-04
260	42	43	synonym	\N	2025-10-20 22:04:31.783427-04
261	43	42	synonym	\N	2025-10-20 22:04:31.783797-04
262	42	44	synonym	\N	2025-10-20 22:04:31.784505-04
263	44	42	synonym	\N	2025-10-20 22:04:31.784831-04
264	42	45	synonym	\N	2025-10-20 22:04:31.785582-04
265	45	42	synonym	\N	2025-10-20 22:04:31.786026-04
266	42	46	synonym	\N	2025-10-20 22:04:31.786784-04
267	46	42	synonym	\N	2025-10-20 22:04:31.787126-04
268	42	47	synonym	\N	2025-10-20 22:04:31.787978-04
269	47	42	synonym	\N	2025-10-20 22:04:31.788378-04
270	42	48	antonym	\N	2025-10-20 22:04:31.789085-04
271	42	49	antonym	\N	2025-10-20 22:04:31.789802-04
272	42	50	antonym	\N	2025-10-20 22:04:31.790513-04
273	42	51	antonym	\N	2025-10-20 22:04:31.791249-04
274	42	52	antonym	\N	2025-10-20 22:04:31.792068-04
275	42	53	related	\N	2025-10-20 22:04:31.792947-04
276	42	54	related	\N	2025-10-20 22:04:31.805362-04
277	42	55	related	\N	2025-10-20 22:04:31.806585-04
278	56	57	synonym	\N	2025-10-20 22:04:31.815766-04
279	57	56	synonym	\N	2025-10-20 22:04:31.816165-04
280	56	58	synonym	\N	2025-10-20 22:04:31.817035-04
281	58	56	synonym	\N	2025-10-20 22:04:31.817368-04
282	56	59	synonym	\N	2025-10-20 22:04:31.818189-04
283	59	56	synonym	\N	2025-10-20 22:04:31.818515-04
284	56	60	synonym	\N	2025-10-20 22:04:31.819241-04
285	60	56	synonym	\N	2025-10-20 22:04:31.819575-04
286	56	61	synonym	\N	2025-10-20 22:04:31.820467-04
287	61	56	synonym	\N	2025-10-20 22:04:31.820822-04
288	56	62	synonym	\N	2025-10-20 22:04:31.82155-04
289	62	56	synonym	\N	2025-10-20 22:04:31.821911-04
290	56	63	antonym	\N	2025-10-20 22:04:31.822756-04
291	56	64	antonym	\N	2025-10-20 22:04:31.823498-04
292	56	65	antonym	\N	2025-10-20 22:04:31.824252-04
293	56	66	antonym	\N	2025-10-20 22:04:31.825049-04
294	56	67	related	\N	2025-10-20 22:04:31.825899-04
295	56	68	related	\N	2025-10-20 22:04:31.826703-04
296	56	69	related	\N	2025-10-20 22:04:31.827507-04
297	70	71	synonym	\N	2025-10-20 22:04:31.836666-04
298	71	70	synonym	\N	2025-10-20 22:04:31.837021-04
299	70	72	synonym	\N	2025-10-20 22:04:31.837729-04
300	72	70	synonym	\N	2025-10-20 22:04:31.838035-04
301	70	73	synonym	\N	2025-10-20 22:04:31.838779-04
302	73	70	synonym	\N	2025-10-20 22:04:31.839128-04
303	70	74	synonym	\N	2025-10-20 22:04:31.839797-04
304	74	70	synonym	\N	2025-10-20 22:04:31.840097-04
305	70	75	synonym	\N	2025-10-20 22:04:31.840731-04
306	75	70	synonym	\N	2025-10-20 22:04:31.841073-04
307	70	76	antonym	\N	2025-10-20 22:04:31.841902-04
308	70	77	antonym	\N	2025-10-20 22:04:31.842721-04
309	70	78	antonym	\N	2025-10-20 22:04:31.843545-04
310	70	79	antonym	\N	2025-10-20 22:04:31.844329-04
311	70	80	antonym	\N	2025-10-20 22:04:31.845093-04
312	70	81	related	\N	2025-10-20 22:04:31.845939-04
313	70	82	related	\N	2025-10-20 22:04:31.846708-04
314	83	84	synonym	\N	2025-10-20 22:04:31.857415-04
315	84	83	synonym	\N	2025-10-20 22:04:31.857753-04
316	83	85	synonym	\N	2025-10-20 22:04:31.858474-04
317	85	83	synonym	\N	2025-10-20 22:04:31.858803-04
318	83	86	synonym	\N	2025-10-20 22:04:31.860068-04
319	86	83	synonym	\N	2025-10-20 22:04:31.860416-04
320	83	87	synonym	\N	2025-10-20 22:04:31.861909-04
321	87	83	synonym	\N	2025-10-20 22:04:31.86223-04
322	83	88	synonym	\N	2025-10-20 22:04:31.862933-04
323	88	83	synonym	\N	2025-10-20 22:04:31.863232-04
324	83	89	antonym	\N	2025-10-20 22:04:31.863939-04
325	83	90	antonym	\N	2025-10-20 22:04:31.864676-04
326	83	91	antonym	\N	2025-10-20 22:04:31.865352-04
327	83	92	antonym	\N	2025-10-20 22:04:31.866062-04
328	83	93	related	\N	2025-10-20 22:04:31.866723-04
451	187	188	synonym	\N	2025-10-21 14:12:26.363397-04
452	188	187	synonym	\N	2025-10-21 14:12:26.36502-04
453	187	189	synonym	\N	2025-10-21 14:12:26.366132-04
454	189	187	synonym	\N	2025-10-21 14:12:26.366634-04
455	187	190	synonym	\N	2025-10-21 14:12:26.367416-04
456	190	187	synonym	\N	2025-10-21 14:12:26.367762-04
457	187	191	synonym	\N	2025-10-21 14:12:26.369873-04
458	191	187	synonym	\N	2025-10-21 14:12:26.370231-04
459	187	192	synonym	\N	2025-10-21 14:12:26.371131-04
460	192	187	synonym	\N	2025-10-21 14:12:26.371452-04
461	187	193	antonym	\N	2025-10-21 14:12:26.372182-04
462	187	194	antonym	\N	2025-10-21 14:12:26.372981-04
463	187	195	antonym	\N	2025-10-21 14:12:26.373927-04
464	187	196	antonym	\N	2025-10-21 14:12:26.37481-04
465	187	197	related	\N	2025-10-21 14:12:26.375946-04
466	187	198	related	\N	2025-10-21 14:12:26.376766-04
467	187	199	related	\N	2025-10-21 14:12:26.377512-04
468	187	200	related	\N	2025-10-21 14:12:26.378257-04
785	443	444	synonym	\N	2025-10-25 18:31:27.269822-04
786	444	443	synonym	\N	2025-10-25 18:31:27.275185-04
787	443	197	synonym	\N	2025-10-25 18:31:27.278456-04
788	197	443	synonym	\N	2025-10-25 18:31:27.279629-04
789	443	446	synonym	\N	2025-10-25 18:31:27.281059-04
790	446	443	synonym	\N	2025-10-25 18:31:27.296836-04
791	443	447	synonym	\N	2025-10-25 18:31:27.308318-04
792	447	443	synonym	\N	2025-10-25 18:31:27.319647-04
793	443	448	synonym	\N	2025-10-25 18:31:27.328734-04
794	448	443	synonym	\N	2025-10-25 18:31:27.333937-04
795	443	449	synonym	\N	2025-10-25 18:31:27.346893-04
796	449	443	synonym	\N	2025-10-25 18:31:27.353319-04
797	443	450	antonym	\N	2025-10-25 18:31:27.357381-04
798	443	451	antonym	\N	2025-10-25 18:31:27.364337-04
799	443	452	antonym	\N	2025-10-25 18:31:27.383699-04
800	443	453	antonym	\N	2025-10-25 18:31:27.387271-04
801	443	454	related	\N	2025-10-25 18:31:27.390416-04
802	443	444	related	\N	2025-10-25 18:31:27.391666-04
803	443	456	related	\N	2025-10-25 18:31:27.392703-04
804	457	458	synonym	\N	2025-10-25 18:31:27.457249-04
805	458	457	synonym	\N	2025-10-25 18:31:27.457756-04
806	457	459	synonym	\N	2025-10-25 18:31:27.458715-04
807	459	457	synonym	\N	2025-10-25 18:31:27.45913-04
808	457	460	synonym	\N	2025-10-25 18:31:27.460006-04
809	460	457	synonym	\N	2025-10-25 18:31:27.460375-04
810	457	461	synonym	\N	2025-10-25 18:31:27.461186-04
811	461	457	synonym	\N	2025-10-25 18:31:27.461518-04
812	457	462	synonym	\N	2025-10-25 18:31:27.462275-04
813	462	457	synonym	\N	2025-10-25 18:31:27.462616-04
814	457	463	antonym	\N	2025-10-25 18:31:27.463362-04
815	457	464	antonym	\N	2025-10-25 18:31:27.464203-04
816	457	465	antonym	\N	2025-10-25 18:31:27.465102-04
817	457	466	antonym	\N	2025-10-25 18:31:27.465962-04
818	457	467	related	\N	2025-10-25 18:31:27.467052-04
819	457	468	related	\N	2025-10-25 18:31:27.468434-04
820	469	470	synonym	\N	2025-10-25 18:31:27.501398-04
821	470	469	synonym	\N	2025-10-25 18:31:27.502113-04
822	469	471	synonym	\N	2025-10-25 18:31:27.503282-04
823	471	469	synonym	\N	2025-10-25 18:31:27.504912-04
824	469	472	synonym	\N	2025-10-25 18:31:27.505844-04
825	472	469	synonym	\N	2025-10-25 18:31:27.506229-04
826	469	473	synonym	\N	2025-10-25 18:31:27.507335-04
827	473	469	synonym	\N	2025-10-25 18:31:27.507805-04
828	469	474	synonym	\N	2025-10-25 18:31:27.508722-04
829	474	469	synonym	\N	2025-10-25 18:31:27.509067-04
830	469	475	antonym	\N	2025-10-25 18:31:27.509814-04
831	469	476	antonym	\N	2025-10-25 18:31:27.51052-04
832	469	477	antonym	\N	2025-10-25 18:31:27.514017-04
833	469	478	antonym	\N	2025-10-25 18:31:27.514915-04
834	469	479	antonym	\N	2025-10-25 18:31:27.515746-04
835	469	480	related	\N	2025-10-25 18:31:27.51711-04
836	469	470	related	\N	2025-10-25 18:31:27.518668-04
837	469	471	related	\N	2025-10-25 18:31:27.525122-04
838	483	484	synonym	\N	2025-10-25 18:31:27.546093-04
839	484	483	synonym	\N	2025-10-25 18:31:27.546548-04
840	483	485	synonym	\N	2025-10-25 18:31:27.549515-04
841	485	483	synonym	\N	2025-10-25 18:31:27.550011-04
842	483	486	synonym	\N	2025-10-25 18:31:27.552644-04
843	486	483	synonym	\N	2025-10-25 18:31:27.55316-04
844	483	487	synonym	\N	2025-10-25 18:31:27.5541-04
845	487	483	synonym	\N	2025-10-25 18:31:27.554544-04
846	483	488	synonym	\N	2025-10-25 18:31:27.555521-04
847	488	483	synonym	\N	2025-10-25 18:31:27.555938-04
848	483	489	antonym	\N	2025-10-25 18:31:27.557263-04
849	483	490	antonym	\N	2025-10-25 18:31:27.560095-04
850	483	491	antonym	\N	2025-10-25 18:31:27.562125-04
851	483	492	antonym	\N	2025-10-25 18:31:27.563438-04
852	483	488	related	\N	2025-10-25 18:31:27.565577-04
853	483	484	related	\N	2025-10-25 18:31:27.566805-04
854	483	485	related	\N	2025-10-25 18:31:27.570429-04
855	496	497	synonym	\N	2025-10-25 18:31:27.609686-04
856	497	496	synonym	\N	2025-10-25 18:31:27.610551-04
857	496	498	synonym	\N	2025-10-25 18:31:27.612049-04
858	498	496	synonym	\N	2025-10-25 18:31:27.612546-04
859	496	499	synonym	\N	2025-10-25 18:31:27.616094-04
860	499	496	synonym	\N	2025-10-25 18:31:27.617061-04
861	496	500	synonym	\N	2025-10-25 18:31:27.61836-04
862	500	496	synonym	\N	2025-10-25 18:31:27.61907-04
863	496	501	synonym	\N	2025-10-25 18:31:27.620452-04
864	501	496	synonym	\N	2025-10-25 18:31:27.620914-04
865	496	502	synonym	\N	2025-10-25 18:31:27.621879-04
866	502	496	synonym	\N	2025-10-25 18:31:27.622314-04
867	496	503	antonym	\N	2025-10-25 18:31:27.623323-04
868	496	504	antonym	\N	2025-10-25 18:31:27.624275-04
869	496	505	antonym	\N	2025-10-25 18:31:27.625287-04
870	496	506	antonym	\N	2025-10-25 18:31:27.626184-04
871	496	507	antonym	\N	2025-10-25 18:31:27.62707-04
872	496	508	related	\N	2025-10-25 18:31:27.628123-04
873	496	509	related	\N	2025-10-25 18:31:27.629177-04
874	496	510	related	\N	2025-10-25 18:31:27.632325-04
875	511	512	synonym	\N	2025-10-25 18:31:27.646734-04
876	512	511	synonym	\N	2025-10-25 18:31:27.647161-04
877	511	513	synonym	\N	2025-10-25 18:31:27.648087-04
878	513	511	synonym	\N	2025-10-25 18:31:27.648578-04
879	511	514	synonym	\N	2025-10-25 18:31:27.650002-04
880	514	511	synonym	\N	2025-10-25 18:31:27.66222-04
881	511	515	synonym	\N	2025-10-25 18:31:27.664615-04
882	515	511	synonym	\N	2025-10-25 18:31:27.665567-04
883	511	516	synonym	\N	2025-10-25 18:31:27.668465-04
884	516	511	synonym	\N	2025-10-25 18:31:27.669266-04
885	511	517	synonym	\N	2025-10-25 18:31:27.670269-04
886	517	511	synonym	\N	2025-10-25 18:31:27.674276-04
887	511	63	antonym	\N	2025-10-25 18:31:27.675978-04
888	511	519	antonym	\N	2025-10-25 18:31:27.67724-04
889	511	520	antonym	\N	2025-10-25 18:31:27.68055-04
890	511	521	antonym	\N	2025-10-25 18:31:27.681462-04
891	511	522	antonym	\N	2025-10-25 18:31:27.682389-04
892	511	523	related	\N	2025-10-25 18:31:27.683355-04
893	511	524	related	\N	2025-10-25 18:31:27.684303-04
894	511	525	related	\N	2025-10-25 18:31:27.685164-04
895	511	526	related	\N	2025-10-25 18:31:27.68607-04
896	527	528	synonym	\N	2025-10-25 18:31:27.722053-04
897	528	527	synonym	\N	2025-10-25 18:31:27.72254-04
898	527	529	synonym	\N	2025-10-25 18:31:27.723508-04
899	529	527	synonym	\N	2025-10-25 18:31:27.723902-04
900	527	530	synonym	\N	2025-10-25 18:31:27.724769-04
901	530	527	synonym	\N	2025-10-25 18:31:27.725122-04
902	527	531	synonym	\N	2025-10-25 18:31:27.725874-04
903	531	527	synonym	\N	2025-10-25 18:31:27.726182-04
904	527	532	synonym	\N	2025-10-25 18:31:27.727197-04
905	532	527	synonym	\N	2025-10-25 18:31:27.727639-04
906	527	533	synonym	\N	2025-10-25 18:31:27.72898-04
907	533	527	synonym	\N	2025-10-25 18:31:27.729365-04
908	527	534	antonym	\N	2025-10-25 18:31:27.730155-04
909	527	535	antonym	\N	2025-10-25 18:31:27.730995-04
910	527	536	antonym	\N	2025-10-25 18:31:27.731819-04
911	527	537	antonym	\N	2025-10-25 18:31:27.732719-04
912	527	538	antonym	\N	2025-10-25 18:31:27.733838-04
913	527	539	related	\N	2025-10-25 18:31:27.734804-04
914	527	540	related	\N	2025-10-25 18:31:27.735812-04
915	527	541	related	\N	2025-10-25 18:31:27.736744-04
916	542	543	synonym	\N	2025-10-25 18:31:27.746233-04
917	543	542	synonym	\N	2025-10-25 18:31:27.746557-04
918	542	544	synonym	\N	2025-10-25 18:31:27.747397-04
919	544	542	synonym	\N	2025-10-25 18:31:27.747751-04
920	542	545	synonym	\N	2025-10-25 18:31:27.748595-04
921	545	542	synonym	\N	2025-10-25 18:31:27.748948-04
922	542	546	synonym	\N	2025-10-25 18:31:27.749823-04
923	546	542	synonym	\N	2025-10-25 18:31:27.750263-04
924	542	547	synonym	\N	2025-10-25 18:31:27.751194-04
925	547	542	synonym	\N	2025-10-25 18:31:27.751688-04
926	542	548	antonym	\N	2025-10-25 18:31:27.752644-04
927	542	549	antonym	\N	2025-10-25 18:31:27.753472-04
928	542	550	antonym	\N	2025-10-25 18:31:27.754304-04
929	542	551	antonym	\N	2025-10-25 18:31:27.755664-04
930	542	552	antonym	\N	2025-10-25 18:31:27.758908-04
931	542	553	related	\N	2025-10-25 18:31:27.75967-04
932	542	554	related	\N	2025-10-25 18:31:27.762908-04
\.


--
-- Data for Name: word_root_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.word_root_links (vocab_id, root_id, relation_description) FROM stdin;
1	1	Direct descendant via compound 'omittere' (ob- + mittere)
\.


--
-- Data for Name: word_timeline_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.word_timeline_events (id, vocab_id, century, exact_date, language_stage, region, semantic_focus, event_text, created_at, sibling_words, context) FROM stdin;
314	443	1	\N	\N	\N	\N	In Rome, he was *testare*—'to bear witness.' Built from *testis*, the witness who stands by to see. The law required three witnesses for a will: three who would attest that yes, this was the voice of the dying. To attest was to put your body in the way of truth—to stand where you had been and speak what you had seen. It was physical presence made vocal.	2025-10-27 03:01:11.491559-04	{testis,testamentum,testari}	Roman legal and testamentary practice where oral testimony was binding evidence.
315	443	14	\N	\N	\N	\N	When English courts took shape, Attest crossed from Old French *attester*. He carried the stamp of formality. Deeds were attested by witnesses; charters bore attestations from clerks. He moved from spoken truth to written proof. The witness still stood, but now his words lived on in ink. Attest became the bridge between seeing and lasting: what the eye witnessed, the document preserved.	2025-10-27 03:01:11.497508-04	{attestation,testimony}	Medieval English legal and bureaucratic systems formalizing evidence through written records.
316	443	17	\N	\N	\N	\N	The age of exploration brought new witnesses. Travellers attested to wonders; historians to facts; naturalists to species. But as print multiplied voices, attest began to carry doubt. To attest was not just to affirm but to stake one's name on it. The word learned the weight of reputation—the risk of being wrong in public, for all to see.	2025-10-27 03:01:11.498414-04	{attestation}	Scientific and historical discourse establishing facts through cited evidence and testimony.
317	443	19	\N	\N	\N	\N	In the industrial age, Attest grew quieter, more technical. Documents attested to births and deaths; certificates to skills and qualifications. He had passed from the drama of the courtroom to the routine of the office. The standing witness became a form to sign, a seal to affix. What began as the body's truth had become the system's record.	2025-10-27 03:01:11.499056-04	{}	Modern bureaucratic and administrative systems reducing personal testimony to procedural verification.
318	457	9	\N	\N	\N	\N	From Old English *pæll*, he meant 'a cloak'—rich fabric draped over shoulders. Kings wore palls of purple; saints were buried under palls of silk. He was luxury before he was sorrow. But cloth is born to cover, and what it covers changes its nature. By the time Middle English spoke his name, he had learned to shield the face of death.	2025-10-27 03:01:11.568425-04	{appal,pale}	Anglo-Saxon and early medieval textile culture where rich cloth marked status and ritual.
319	457	14	\N	\N	\N	\N	When plague swept Europe, Pall found his calling. Funeral rites stretched the pall over coffins—black wool for the poor, velvet for the rich, but always the same shield between the living and what they buried. He became the ritual cloth of separation: what the eye could not bear to see, he hid. From rich cloak to funeral shroud, luxury became dignity in death.	2025-10-27 03:01:11.569235-04	{pallium,palliate}	Medieval Christian burial practices formalizing the covering of the dead as sacred ritual.
320	457	17	\N	\N	\N	\N	Poets took him from the churchyard. Smoke hung like a pall over burning cities. Silence fell like a pall over crowds. He had learned to stretch—no longer just cloth but anything heavy, dark, settling. The metaphorical pall became more common than the literal one. He became atmosphere: the feeling of weight that comes from nowhere visible.	2025-10-27 03:01:11.569861-04	{}	Early modern English poetry expanding concrete images into emotional metaphors.
321	457	19	\N	\N	\N	\N	As a verb, Pall learned to tire. The joke palled; the beauty palled; repetition palled everything. The same cloth that covered death now covered enjoyment. Not shock but weariness. Not grief but boredom. He had learned a new skill: the gentle killing of interest, the slow burial of what once delighted. The covering that hid death also muffled life.	2025-10-27 03:01:11.570529-04	{}	Victorian and Romantic literature exploring psychological states of ennui and melancholy.
322	469	14	\N	\N	\N	\N	From Lombard merchants came *lumber*—'pawn,' goods stored in a Lombard's shop. To lumber a room meant to fill it with stored things, cluttering the space. Lumber became the word for awkward bulk: furniture too big for doorways, objects blocking the way. He began as commerce and ended as obstruction. The slow merchant's stock became the slow creature's gait.	2025-10-27 03:01:11.573043-04	{lumber,lombard}	Medieval trade where Lombard moneylenders and pawnbrokers stored goods that blocked spaces.
323	469	16	\N	\N	\N	\N	As English explored new worlds, Lumbering met the forest. *Lumber* came to mean timber, and to lumber meant to cut it clumsily, to move it heavily. The word that named stored goods now named fallen trees. Merchants' stockrooms and loggers' rivers both held the same quality: things too heavy to move with grace. Bulk became movement—the awkward hauling of weight.	2025-10-27 03:01:11.57355-04	{lumber,timber}	Colonial and early modern resource extraction where heavy materials required cumbersome transport.
324	469	18	\N	\N	\N	\N	When writers described animals, they summoned him. The bear lumbered through snow; the elephant lumbered into the clearing. He had learned to walk. Not graceful movement but the honest gait of mass: each step deliberate, ground-giving, leaving prints too deep to fill. He became the poetry of weight—not beautiful but true, not fast but certain.	2025-10-27 03:01:11.574082-04	{}	Natural history writing exploring animal behavior and movement patterns.
215	1	1	\N	\N	\N	\N	Long ago, in Rome, he was *impedire*—'to shackle the feet.' Built from *in-* ('in, upon') and *pes/pedis* ('foot'), he was born of the body. To impede was to bind, to trap motion itself. Soldiers felt him in their tangled nets; lawyers in their endless petitions. His world was literal: movement stopped by weight or chain.	2025-10-24 19:30:02.520572-04	{pedis,expedire,impedimentum}	Roman military and legal life where action and obstruction were physical facts.
216	1	14	\N	\N	\N	\N	When the Empire’s dust settled and prayers replaced campaigns, Impede crossed into Old French as *empedier*. He kept his fetters, but their meaning shifted. The soul now had feet. To sin was to stumble; to be virtuous was to walk unchained. In sermons he became the enemy of grace—the snag that kept the spirit from moving freely toward God.	2025-10-24 19:30:02.522687-04	{empescher,empêchement}	Feudal Christianity moralized physical delay into spiritual bondage.
217	1	16	\N	\N	\N	\N	Then the Renaissance arrived, and with it, motion itself became a metaphor. Discovery, reform, progress—everyone was moving somewhere new. Impede, still dragging his ancient chains, now followed minds instead of bodies. He was no longer evil, just inconvenient: the bureaucrat’s delay, the inventor’s frustration, the scholar’s pause.	2025-10-24 19:30:02.523597-04	{expedite,impediment}	Humanist and bureaucratic cultures reframed movement as intellectual and social progress.
218	1	19	\N	\N	\N	\N	By the industrial age, Impede had lost his shackles but kept his habit. He haunted the gears of systems, not the feet of soldiers. Processes stalled; reforms slowed; traffic stopped. The moral heat was gone—only procedure remained. What began in the body ended in the machine.	2025-10-24 19:30:02.524438-04	{}	Modern administrative and technological systems turned moral delay into mechanical inefficiency.
219	13	1	\N	\N	\N	\N	In Rome, he was *inhaerēre*—'to stick in, to cling to.' His body was a burr caught in wool, wax pressed to marble, paint holding fast to plaster. From this touch grew an idea: some things exist *within* others, inseparable and abiding. Philosophers used him to name qualities that lived inside matter itself.	2025-10-24 19:30:02.52611-04	{adhere,cohere,haerere}	Roman and Scholastic Latin describing properties residing 'in' a substance rather than external to it.
220	13	14	\N	\N	\N	\N	In the halls of medieval scholars, Inherent put on robes and became a word of metaphysics. Through Old French *inherer* and Latin *inhaerens*, he entered English carrying Aristotle’s logic of substance and accident. Virtue was said to inhere in the soul; whiteness to inhere in snow. He spoke of what could never be separated from what it was.	2025-10-24 19:30:02.526913-04	{adhérent,cohérent}	Scholastic theology and Aristotelian philosophy shaping European metaphysical vocabulary.
221	13	17	\N	\N	\N	\N	When the Enlightenment dawned, Inherent left the cloister for the forum. He began to speak of rights and dignity—qualities not bestowed but possessed. What once described color in marble now described worth in humankind. He became political, carrying the old logic of internal belonging into the language of freedom.	2025-10-24 19:30:02.527954-04	{}	Natural-law and early liberal philosophy expanding metaphysical inherence into moral and political discourse.
222	13	20	\N	\N	\N	\N	Today he moves quietly through science and systems: the inherent bias of data, the inherent stability of molecules. The stickiness of matter has become the grammar of structure. The touch is gone, but its logic remains—what belongs within still holds everything together.	2025-10-24 19:30:02.528855-04	{}	Modern scientific and analytic usage turning metaphysical inherence into structural description.
223	27	1	\N	\N	\N	\N	In the Latin world, he began as *cohaerēre*—'to stick together.' His body was glue, sap, wax. He clung where things met: brick to mortar, vine to trellis, friend to friend. *Haerēre* meant to cling, and *co-* joined him to others. He was the language of closeness before it was a metaphor.	2025-10-24 19:30:02.530126-04	{adhere,inherent,cohere}	Roman and Scholastic Latin using adhesion as a metaphor for both physical and moral unity.
224	27	17	\N	\N	\N	\N	When the thinkers of the new sciences began to name the secret laws of matter, they summoned him again. *Cohere*, *cohesion*—the way dust joins into drop, drop into stone. He became a principle, not just a feeling. Boyle and Newton made him a law of nature: the power that binds atoms as friendship binds men.	2025-10-24 19:30:02.530934-04	{adhesion,aggregation}	Scientific revolution defining cohesion as the force uniting particles or bodies.
225	27	19	\N	\N	\N	\N	The industrial age stretched him further. Machines turned, cities swelled, and people began to ask what held them all together. Cohesive took on new tasks—describing nations, crowds, stories, minds. The bond of molecules became the bond of meaning. He was no longer just physical; he was social, intellectual, and moral.	2025-10-24 19:30:02.531621-04	{}	Sociology, psychology, and rhetoric borrowed scientific metaphors to describe unity in human systems.
226	27	20	\N	\N	\N	\N	Now Cohesive lives in offices and classrooms, in design briefs and mission statements. His Latin body is gone, but his instinct endures: to pull the scattered into shape. Every time a team holds, or an argument flows, he’s there—quiet, connecting, necessary.	2025-10-24 19:30:02.532277-04	{}	Modern management, communication theory, and design emphasizing unity through integration.
227	42	19	\N	\N	\N	\N	In the rough talk of the 1800s frontier, 'scattershot' was pure mechanics: the spray of pellets from a shotgun’s mouth. It was a hunter’s word, meaning range at the cost of precision. A scattershot could strike anything or nothing. The image belonged to smoke, echo, and chance.	2025-10-24 19:30:02.533757-04	{shotgun,buckshot}	American hunting and frontier language valuing practicality over precision.
228	42	20	\N	\N	\N	\N	After the wars, the world grew obsessed with targets—goals, quotas, metrics. Into that culture, Scattershot wandered, half feral. He was the one who fired ideas instead of bullets: policies that sprawled, arguments that sprawled wider. The old gunmetal word now measured intellectual mess.	2025-10-24 19:30:02.534432-04	{broadside,spray}	Postwar bureaucratic and managerial discourse moralizing precision as efficiency.
229	42	21	\N	\N	\N	\N	Now he’s everywhere—meetings, essays, start-ups. Scattershot speaks of the rush to do, to say, to solve before thinking. He carries a faint scent of gunpowder still, the memory of the hunt. But his meaning is softer now: not danger, just disarray—the price of trying to hit everything at once.	2025-10-24 19:30:02.535102-04	{}	Contemporary colloquial English across media, technology, and education.
230	56	1	\N	\N	\N	\N	In Rome, he was *saliēns*—'leaping, springing forth.' The poets used him for fountains, fish, the pulse of joy. To leap was to live: the verb *salīre* carried vitality itself. Salient began as motion, not metaphor.	2025-10-24 19:30:02.53639-04	{salire,resilire,assilire}	Roman poetic and descriptive vocabulary where leaping marked life and vigor.
231	56	16	\N	\N	\N	\N	By the Renaissance, *saillant* in French meant 'jutting out'—a wall that leaned toward the world, a bastion pointing at the horizon. English borrowed him as an engineer’s and soldier’s term: the salient angle of a fortress, the place that struck first and was struck hardest.	2025-10-24 19:30:02.537009-04	{assaillant,ressortissant}	Military and architectural vocabulary linking geometry with aggression and defense.
232	56	17	\N	\N	\N	\N	Then the leap turned inward. Philosophers and rhetoricians called an idea 'salient' when it sprang to the mind. The fortification became a thought: something projecting beyond the rest. To leap became to signify.	2025-10-24 19:30:02.537658-04	{conspicuous,prominent}	Early modern intellectual and rhetorical writing emphasizing clarity and distinction.
233	56	19	\N	\N	\N	\N	By the modern age, Salient had settled into analysis and argument. He no longer moved; he marked. To be salient was to stand out by design, not by motion. Yet in every use, his ancient spring survives—the mind’s leap made permanent in language.	2025-10-24 19:30:02.538191-04	{}	Scientific, analytic, and journalistic use of 'salient' for central data or defining traits.
234	70	1	\N	\N	\N	\N	In Rome, he was *perfungī*—'to do through.' A soldier’s word, a clerk’s word. He lived in the world of completion, not care. He finished what others feared to start, and thought that enough. His virtue was endurance, not tenderness.	2025-10-24 19:30:02.539108-04	{fungi,function,defunctus}	Roman civic and military discipline: the ethic of finishing as moral strength.
235	70	12	\N	\N	\N	\N	When the empire gave way to prayer, he followed into the church. *Perfunctorius* began to mean a prayer said by habit. The form was right, but the heart was missing. He was no longer a soldier—he was a monk murmuring words he no longer felt.	2025-10-24 19:30:02.539564-04	{function,defunct}	Medieval religious culture valuing inward sincerity over outward performance.
236	70	16	\N	\N	\N	\N	In the English tongue he found guilt waiting for him. Renaissance writers turned him into a warning: the worker of hollow deeds. The Reformation made him blush—the new world wanted feeling, and he had only form.	2025-10-24 19:30:02.540034-04	{}	Renaissance and Reformation humanism redefined moral value through authenticity.
237	70	19	\N	\N	\N	\N	Then came the factories. The machines welcomed him home. Every lever pulled, every stamp struck—done through, done well, done empty. The virtue of completion returned, but without pride. He had become the rhythm of repetition.	2025-10-24 19:30:02.540482-04	{}	Industrial revolution and the rise of mechanical labor and bureaucratic routine.
238	70	21	\N	\N	\N	\N	Now he lives in notifications and signatures. He sends the email, taps the emoji, finishes the task. Still functioning, still performing. The discipline of Rome survives—but the soul of it has gone missing.	2025-10-24 19:30:02.541253-04	{}	Digital-age communication and emotional automation.
239	83	1	\N	\N	\N	\N	In Rome, he was *omittere*—'to let go, to send away.' Built from *ob-* ('away') + *mittere* ('to send'), he belonged to a family of doers—*remittere, permittere, submittere*. They all acted; he refrained. His meaning was the negative space of will: to set aside, to leave undone.	2025-10-24 19:30:02.542359-04	{mittere,remittere,permittere,submittere,transmittere}	Roman legal and rhetorical life: omission as deliberate restraint rather than failure.
240	83	12	\N	\N	\N	\N	In the age of confession, he was moralized. *Omettre* became a sin of silence—a thing not done when duty called. His neutrality vanished. To omit was to fail the soul, not the sentence.	2025-10-24 19:30:02.542942-04	{commettre,soumettre}	Medieval Christian theology: the opposition of commission and omission as moral binaries.
241	83	15	\N	\N	\N	\N	When the monks became clerks and the parchment became proof, Omit found a new stage. He lived in records now, where what was left out could ruin fortunes. His sin became paperwork.	2025-10-24 19:30:02.543555-04	{}	Late medieval bureaucracy and recordkeeping linking omission to legal liability.
242	83	16	\N	\N	\N	\N	With printing presses and ledgers multiplying, Omit shed his guilt. To omit was now an act of editing—a choice, not a failure. The blank became a craft.	2025-10-24 19:30:02.544223-04	{}	Renaissance print culture and textual specialization transforming omission into technique.
243	83	20	\N	\N	\N	\N	Now he walks between worlds: neutral in documents, moral in sermons, rhetorical in debate. He survives in phrases like fossils—'sins of omission,' 'lies of omission'—ghosts of the age when absence was blame.	2025-10-24 19:30:02.544745-04	{}	Modern English separating moral, legal, and editorial discourses.
244	187	1	\N	\N	\N	\N	In Rome, she was *verisimilitudo*—'truthlikeness.' Philosophers built her from *verus* ('true') and *similis* ('like'), a concept born of resemblance. She lived in the space between certainty and illusion, where rhetoricians worked. To have verisimilitude was to speak what seemed true when proof was distant. Cicero knew her well: she was the orator's art.	2025-10-24 19:30:02.545691-04	{verus,similis,similitudo,veritas}	Roman rhetoric and philosophy distinguishing probable truth from absolute certainty.
245	187	14	\N	\N	\N	\N	When Aristotle's *Poetics* returned to European thought through Arabic translations, Verisimilitude found new purpose. Medieval scholars called her the soul of narrative—what made a tale feel true even when invention shaped it. She wasn't deception; she was craft. Fiction could teach by seeming real.	2025-10-24 19:30:02.546182-04	{vraisemblance,probabilis}	Scholastic rediscovery of Aristotelian poetics and the theory of mimesis.
246	187	17	\N	\N	\N	\N	In England's coffee houses and theaters, she arrived as *verisimilitude*—French *vraisemblance* dressed in Latin gravity. Critics demanded it of playwrights; novelists studied it like scripture. Defoe and Richardson built worlds that breathed because of her. She had become the measure of art: not truth, but its convincing performance.	2025-10-24 19:30:02.546741-04	{plausibility,probability}	Rise of the novel and neoclassical literary criticism valuing realistic representation.
247	187	19	\N	\N	\N	\N	The realists took her seriously—Flaubert, Tolstoy, Eliot. Every detail mattered now. Verisimilitude demanded research, observation, the texture of lived life. She grew exacting, almost scientific. To write without her was to betray the reader. She had become the conscience of fiction.	2025-10-24 19:30:02.547261-04	{realism,naturalism}	Realist and naturalist movements prioritizing documentary accuracy in literature.
248	187	20	\N	\N	\N	\N	In courtrooms she found work: forensic verisimilitude, the story that fits the evidence. In cinema she became spectacle: CGI that feels tangible, worlds that seem real enough to touch. Philosophers questioned her ethics—could a lie made lifelike be trusted? But she endures, untroubled: wherever truth is absent and belief is needed, she waits.	2025-10-24 19:30:02.547816-04	{}	Legal theory, film studies, and postmodern skepticism about representation and authenticity.
249	187	21	\N	\N	\N	\N	Now she moves through deepfakes and virtual worlds, through user experience design and narrative games. She's become a technology: algorithms that predict believability, interfaces that feel intuitive because they mimic the real. She no longer argues for truth—she engineers its feeling.	2025-10-24 19:30:02.548332-04	{}	Digital media, simulation theory, and UX design valuing intuitive realism.
325	469	19	\N	\N	\N	\N	Steam and steel gave him a voice. Lumbering trains; lumbering factories; lumbering machines that shook the earth. The term that once named awkward creatures now named industrial power. Modernity was big, loud, heavy, slow to start but impossible to stop once moving. Lumbering became the sound of progress itself—cumbersome but inevitable, awkward but unstoppable.	2025-10-27 03:01:11.574674-04	{}	Industrial Revolution where massive machinery defined both economic power and environmental impact.
326	483	17	\N	\N	\N	\N	In the great houses of England, he was born from *hurry-scurry*—chaos made movement. To scurry was to rush about confused, servants running to orders that canceled each other out. He named the flustered gait of urgency, the movement of those who must arrive without knowing why. From hurry came scurry: not just speed but the anxious speed of small creatures before larger ones.	2025-10-27 03:01:11.576933-04	{hurry,hurry-scurry}	Early modern English domestic and social life where service and social obligations created frantic movement.
327	483	19	\N	\N	\N	\N	When naturalists wrote of small animals, Scurry found his true form. Mice scurried through fields; beetles scurried under logs; ants scurried along paths. He became the verb of small haste: not the bold rush of hunters but the furtive dash of the hunted. He carried the sound of small feet on hard ground—the audible anxiety of creatures too small to stand their ground.	2025-10-27 03:01:11.577397-04	{scuttle}	Natural history writing and Victorian literature observing animal behavior and movement patterns.
328	483	19	\N	\N	\N	\N	Workers scurried through workshops; clerks scurried between desks. The word that named animal haste now named human busyness. But scale mattered: to scurry was not to stride but to dart, not to march but to scoot. It suggested movement without dignity—hurried but not powerful, busy but not significant. The small creature's flight became the worker's pace.	2025-10-27 03:01:11.577827-04	{}	Industrial and bureaucratic settings where human labor mimicked the frantic movements of small animals.
329	483	20	\N	\N	\N	\N	Modern life gave him electricity. Feet scurried across screens; thoughts scurried through news; attention itself scurried from device to device. The verb of small movement became the verb of modern distraction: never still, never settled, always moving to the next thing. What began as flight became habit—the perpetual hurry of being that cannot stop.	2025-10-27 03:01:11.578225-04	{}	Contemporary culture of constant motion, digital distraction, and accelerated pace of life.
330	496	9	\N	\N	\N	\N	In Old English, he was *stædfæst*—'firm in place.' *Stæd* meant a place, a standing-ground; *fæst* meant fixed. Together they named what held its spot. Warriors stood steadfast in shield-walls; oaths remained steadfast in memory. He was physical before he was moral—not yet loyalty but position, not yet faith but footing. The stone does not move, the word does not break.	2025-10-27 03:01:11.580039-04	{steadd,fast,stand}	Anglo-Saxon warrior culture where physical steadfastness in battle translated to moral steadfastness in oaths.
331	496	14	\N	\N	\N	\N	When chivalry made virtue ritual, Steadfast put on honor's colors. The knight who stood steadfast in battle stood steadfast in vows. What began as physical holding became moral holding. Fealty, faith, friendship—all required steadfastness. He learned to name not just standing but staying, not just position but persistence. The shield-wall became the oath-wall; the enemy without became the doubt within.	2025-10-27 03:01:11.580456-04	{faithful,constant}	Medieval chivalric codes formalizing loyalty, honor, and unwavering commitment as core virtues.
332	496	17	\N	\N	\N	\N	When poets sang of love, they summoned him. The steadfast heart that beats one name; the steadfast gaze that never strays. He became the language of constancy—not just loyalty but devotion, not just persistence but passion that endures. What began as military courage became romantic fidelity. The standing warrior became the standing lover; the battle-line became the marriage vow.	2025-10-27 03:01:11.58086-04	{}	Renaissance and early modern poetry elevating romantic constancy as supreme virtue.
333	496	19	\N	\N	\N	\N	The Romantics gave him philosophy. Steadfastness became not just virtue but identity—the self that knows itself and holds. In changing times, the steadfast heart stayed true; in shifting values, the steadfast mind held course. He learned the language of authenticity: not stubbornness but integrity, not rigidity but resolve. What could not be moved defined the person who chose not to move.	2025-10-27 03:01:11.581274-04	{}	Romantic and Victorian philosophy valuing authentic selfhood and unwavering personal integrity.
334	511	1	\N	\N	\N	\N	In Rome, he began as *lūcidus*—'bright, shining, clear.' His root was *lūx*, light itself. What was *lūcidus* shone with inner clarity—water you could see through, thoughts that had no shadows. He described what the eye could trust: transparent things, minds without disguise. His power was revelation through visibility.	2025-10-27 03:01:11.583168-04	{lux,lucere,lumen,illustrare}	Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception.
335	511	16	\N	\N	\N	\N	When English scholars reached for Latin to name the act of making clear, they formed *ēlūcidātum*—'to make luminous.' To elucidate was to take what was dark and turn it bright. Philosophers elucidated arguments; poets elucidated mysteries. The word that had meant 'bright' became an action: the deliberate casting of light into obscurity.	2025-10-27 03:01:11.583561-04	{illustrate,illuminate}	Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations.
336	511	18	\N	\N	\N	\N	In the Age of Enlightenment, Elucidate found his calling. Thinkers vowed to elucidate nature, history, the human mind. Reason was the lamp he carried. Every explanation removed one more shadow; every clarification opened another door. He became the verb of understanding—not faith but illumination, not mystery but method.	2025-10-27 03:01:11.583985-04	{clarify,explicate}	Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation.
337	511	20	\N	\N	\N	\N	Now he moves through classrooms and commentaries, through textbooks and analysis. To elucidate is still to bring light, but the light itself has grown ordinary. In a world of footnotes and explanations, he no longer speaks of revelation—only of procedure, the workable task of making the obscure one shade less dark.	2025-10-27 03:01:11.584437-04	{}	Modern educational and analytical discourse where explanation has become routine institutional practice.
338	527	1	\N	\N	\N	\N	In Rome, she was *plaudibilis*—'worthy of applause.' Born from *plaudere*, 'to clap hands,' she named what audiences approved through sound. To be plausible was to earn the crowd's favor, to meet their standards for what deserved applause. She was theater's judgment: not truth but approval, not reality but acceptance.	2025-10-27 03:01:11.586782-04	{plaudere,applaudere,plausus}	Roman rhetorical and theatrical culture where audience approval measured persuasive success.
339	527	17	\N	\N	\N	\N	When Enlightenment thinkers borrowed her, Plausible moved from theater to philosophy. She still asked for approval, but now from reason, not crowds. A plausible argument was one that reasonable minds could accept—not necessarily true, but not obviously false. The applause became internal: the quiet nod of recognition.	2025-10-27 03:01:11.587223-04	{probable,reasonable}	Enlightenment philosophy and probability theory distinguishing appearance from certainty.
340	527	19	\N	\N	\N	\N	Victorian society taught her politeness. To be plausible meant to seem respectable, to wear the mask of propriety. She learned the language of appearances—what could be said in public, what could be defended in good company. Her truth became social acceptability, measured in frowns averted, suspicions eased.	2025-10-27 03:01:11.587695-04	{respectable,acceptable}	Victorian social codes emphasizing proper appearance and public respectability.
341	527	20	\N	\N	\N	\N	Now she negotiates the space between truth and its convenient substitutes. In politics, in media, in everyday claims, plausibility has become currency: not lies, not certainty, but the middle ground of seeming reasonable. She has learned to serve whoever needs belief without proof—the master of appearances, still asking only for applause.	2025-10-27 03:01:11.588278-04	{}	Modern discourse where persuasive presentation competes with factual verification.
342	542	17	\N	\N	\N	\N	In the age of theology, he was born: *ubīque*, 'everywhere.' Latin reached for him when describing the divine—God's presence that filled all places simultaneously. He named what could not be contained: the being whose location was everywhere and nowhere. He was the word of impossibility made grammatical.	2025-10-27 03:01:11.590252-04	{ubique,ubiquitas}	Scholastic and Protestant theology concerning divine omnipresence.
343	542	19	\N	\N	\N	\N	Science borrowed him carefully. The ether was ubiquitous—filling all space without occupying it. Electromagnetic waves were ubiquitous—present in every void. What began as divine attribute became physical property: the quality of being distributed across all points without being localized to any. He had stepped from metaphysics into matter.	2025-10-27 03:01:11.590659-04	{pervasive,omnipresent}	Nineteenth-century physics and metaphysics theorizing universal forces and fields.
344	542	20	\N	\N	\N	\N	Then he learned replication. Brands became ubiquitous; advertisements, ubiquitous; technologies, ubiquitous. He moved from the philosophical to the economic, from the metaphysical to the manufactured. What was everywhere was not divine or physical but commercial—the mark of success measured in total saturation.	2025-10-27 03:01:11.59112-04	{}	Mass media, advertising, and global capitalism distributing products and images universally.
345	542	21	\N	\N	\N	\N	Now he is the air itself: the network that connects everyone, the platform that spans all spaces, the digital that has no absence. Ubiquitous has become the adjective of our age—the word for what cannot be escaped because it has become the medium in which we breathe. His original mystery has been replaced by his accomplished fact.	2025-10-27 03:01:11.591516-04	{}	Digital technology and internet culture creating universal connectivity and constant presence.
\.


--
-- Name: beast_mode_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.beast_mode_attempts_id_seq', 48, true);


--
-- Name: beast_mode_cooldowns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.beast_mode_cooldowns_id_seq', 16, true);


--
-- Name: causal_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.causal_tags_id_seq', 491, true);


--
-- Name: citations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citations_id_seq', 5, true);


--
-- Name: derivations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.derivations_id_seq', 2, true);


--
-- Name: floor_boss_scenarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.floor_boss_scenarios_id_seq', 46, true);


--
-- Name: floors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.floors_id_seq', 26, true);


--
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maps_id_seq', 3, true);


--
-- Name: purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchases_id_seq', 1, false);


--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_attempts_id_seq', 82, true);


--
-- Name: quiz_materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_materials_id_seq', 346, true);


--
-- Name: quiz_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_questions_id_seq', 105, true);


--
-- Name: quizzes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quizzes_id_seq', 1, false);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 138, true);


--
-- Name: root_families_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.root_families_id_seq', 1, true);


--
-- Name: semantic_domains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.semantic_domains_id_seq', 11, true);


--
-- Name: silk_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.silk_transactions_id_seq', 1, false);


--
-- Name: story_comprehension_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.story_comprehension_questions_id_seq', 231, true);


--
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_id_seq', 1, false);


--
-- Name: user_floor_boss_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_floor_boss_attempts_id_seq', 1, false);


--
-- Name: user_map_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_map_progress_id_seq', 3, true);


--
-- Name: user_quiz_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_quiz_progress_id_seq', 28, true);


--
-- Name: user_room_unlocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_room_unlocks_id_seq', 45, true);


--
-- Name: user_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_stats_id_seq', 3, true);


--
-- Name: user_story_study_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_story_study_attempts_id_seq', 40, true);


--
-- Name: user_story_study_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_story_study_progress_id_seq', 4, true);


--
-- Name: user_word_definitions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_word_definitions_id_seq', 47, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 10, true);


--
-- Name: vocab_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vocab_entries_id_seq', 666, true);


--
-- Name: word_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.word_relations_id_seq', 1080, true);


--
-- Name: word_timeline_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.word_timeline_events_id_seq', 345, true);


--
-- Name: beast_mode_attempts beast_mode_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_attempts
    ADD CONSTRAINT beast_mode_attempts_pkey PRIMARY KEY (id);


--
-- Name: beast_mode_cooldowns beast_mode_cooldowns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_cooldowns
    ADD CONSTRAINT beast_mode_cooldowns_pkey PRIMARY KEY (id);


--
-- Name: beast_mode_cooldowns beast_mode_cooldowns_user_id_word_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_cooldowns
    ADD CONSTRAINT beast_mode_cooldowns_user_id_word_id_key UNIQUE (user_id, word_id);


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
-- Name: floor_boss_scenarios floor_boss_scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floor_boss_scenarios
    ADD CONSTRAINT floor_boss_scenarios_pkey PRIMARY KEY (id);


--
-- Name: floors floors_map_id_floor_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_map_id_floor_number_key UNIQUE (map_id, floor_number);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (id);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id);


--
-- Name: quiz_materials quiz_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_materials
    ADD CONSTRAINT quiz_materials_pkey PRIMARY KEY (id);


--
-- Name: quiz_questions quiz_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_questions quiz_questions_word_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_word_id_level_key UNIQUE (word_id, level);


--
-- Name: quizzes quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_floor_id_room_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_floor_id_room_number_key UNIQUE (floor_id, room_number);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


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
-- Name: silk_transactions silk_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.silk_transactions
    ADD CONSTRAINT silk_transactions_pkey PRIMARY KEY (id);


--
-- Name: story_comprehension_questions story_comprehension_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_comprehension_questions
    ADD CONSTRAINT story_comprehension_questions_pkey PRIMARY KEY (id);


--
-- Name: story_comprehension_questions story_comprehension_questions_word_id_century_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_comprehension_questions
    ADD CONSTRAINT story_comprehension_questions_word_id_century_key UNIQUE (word_id, century);


--
-- Name: timeline_event_tags timeline_event_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeline_event_tags
    ADD CONSTRAINT timeline_event_tags_pkey PRIMARY KEY (event_id, tag_id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: user_floor_boss_attempts user_floor_boss_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_floor_boss_attempts
    ADD CONSTRAINT user_floor_boss_attempts_pkey PRIMARY KEY (id);


--
-- Name: user_map_progress user_map_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_map_progress
    ADD CONSTRAINT user_map_progress_pkey PRIMARY KEY (id);


--
-- Name: user_map_progress user_map_progress_user_id_map_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_map_progress
    ADD CONSTRAINT user_map_progress_user_id_map_id_key UNIQUE (user_id, map_id);


--
-- Name: user_quiz_progress user_quiz_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_quiz_progress
    ADD CONSTRAINT user_quiz_progress_pkey PRIMARY KEY (id);


--
-- Name: user_quiz_progress user_quiz_progress_user_id_word_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_quiz_progress
    ADD CONSTRAINT user_quiz_progress_user_id_word_id_key UNIQUE (user_id, word_id);


--
-- Name: user_room_unlocks user_room_unlocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_room_unlocks
    ADD CONSTRAINT user_room_unlocks_pkey PRIMARY KEY (id);


--
-- Name: user_room_unlocks user_room_unlocks_user_id_room_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_room_unlocks
    ADD CONSTRAINT user_room_unlocks_user_id_room_id_key UNIQUE (user_id, room_id);


--
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- Name: user_story_study_attempts user_story_study_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_attempts
    ADD CONSTRAINT user_story_study_attempts_pkey PRIMARY KEY (id);


--
-- Name: user_story_study_progress user_story_study_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_progress
    ADD CONSTRAINT user_story_study_progress_pkey PRIMARY KEY (id);


--
-- Name: user_story_study_progress user_story_study_progress_user_id_word_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_progress
    ADD CONSTRAINT user_story_study_progress_user_id_word_id_key UNIQUE (user_id, word_id);


--
-- Name: user_word_definitions user_word_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_word_definitions
    ADD CONSTRAINT user_word_definitions_pkey PRIMARY KEY (id);


--
-- Name: user_word_definitions user_word_definitions_user_id_word_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_word_definitions
    ADD CONSTRAINT user_word_definitions_user_id_word_id_key UNIQUE (user_id, word_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


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
-- Name: idx_attempts_quiz_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_quiz_id ON public.quiz_attempts USING btree (quiz_id);


--
-- Name: idx_beast_attempts_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beast_attempts_user ON public.beast_mode_attempts USING btree (user_id);


--
-- Name: idx_beast_attempts_word; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beast_attempts_word ON public.beast_mode_attempts USING btree (word_id);


--
-- Name: idx_beast_cooldowns_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beast_cooldowns_user ON public.beast_mode_cooldowns USING btree (user_id);


--
-- Name: idx_beast_cooldowns_word; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beast_cooldowns_word ON public.beast_mode_cooldowns USING btree (word_id);


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
-- Name: idx_floor_boss_scenarios_floor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_floor_boss_scenarios_floor_id ON public.floor_boss_scenarios USING btree (floor_id);


--
-- Name: idx_floors_map_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_floors_map_id ON public.floors USING btree (map_id);


--
-- Name: idx_purchases_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_purchases_user_id ON public.purchases USING btree (user_id);


--
-- Name: idx_quiz_materials_word_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_materials_word_level ON public.quiz_materials USING btree (word_id, level);


--
-- Name: idx_quiz_questions_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_questions_level ON public.quiz_questions USING btree (level);


--
-- Name: idx_quiz_questions_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_questions_word_id ON public.quiz_questions USING btree (word_id);


--
-- Name: idx_quizzes_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quizzes_user_id ON public.quizzes USING btree (user_id);


--
-- Name: idx_quizzes_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quizzes_word_id ON public.quizzes USING btree (word_id);


--
-- Name: idx_rooms_floor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_floor_id ON public.rooms USING btree (floor_id);


--
-- Name: idx_rooms_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_word_id ON public.rooms USING btree (word_id);


--
-- Name: idx_story_comprehension_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_story_comprehension_word_id ON public.story_comprehension_questions USING btree (word_id);


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
-- Name: idx_user_floor_boss_attempts_floor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_floor_boss_attempts_floor_id ON public.user_floor_boss_attempts USING btree (floor_id);


--
-- Name: idx_user_floor_boss_attempts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_floor_boss_attempts_user_id ON public.user_floor_boss_attempts USING btree (user_id);


--
-- Name: idx_user_map_progress_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_map_progress_user_id ON public.user_map_progress USING btree (user_id);


--
-- Name: idx_user_quiz_progress_user_word; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_quiz_progress_user_word ON public.user_quiz_progress USING btree (user_id, word_id);


--
-- Name: idx_user_room_unlocks_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_room_unlocks_room_id ON public.user_room_unlocks USING btree (room_id);


--
-- Name: idx_user_room_unlocks_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_room_unlocks_user_id ON public.user_room_unlocks USING btree (user_id);


--
-- Name: idx_user_story_study_attempts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_story_study_attempts_user_id ON public.user_story_study_attempts USING btree (user_id);


--
-- Name: idx_user_story_study_attempts_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_story_study_attempts_word_id ON public.user_story_study_attempts USING btree (word_id);


--
-- Name: idx_user_story_study_progress_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_story_study_progress_user_id ON public.user_story_study_progress USING btree (user_id);


--
-- Name: idx_user_story_study_progress_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_story_study_progress_word_id ON public.user_story_study_progress USING btree (word_id);


--
-- Name: idx_user_word_definitions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_word_definitions_user_id ON public.user_word_definitions USING btree (user_id);


--
-- Name: idx_user_word_definitions_word_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_word_definitions_word_id ON public.user_word_definitions USING btree (word_id);


--
-- Name: idx_vocab_domain_dom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vocab_domain_dom ON public.vocab_domain_links USING btree (domain_id);


--
-- Name: idx_vocab_domain_vocab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vocab_domain_vocab ON public.vocab_domain_links USING btree (vocab_id);


--
-- Name: idx_vocab_entries_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vocab_entries_status ON public.vocab_entries USING btree (learning_status);


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

CREATE INDEX vocab_long_story_idx ON public.vocab_entries USING gin (to_tsvector('english'::regconfig, story_intro));


--
-- Name: beast_mode_attempts update_beast_mode_attempts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_beast_mode_attempts_updated_at BEFORE UPDATE ON public.beast_mode_attempts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: quiz_questions update_quiz_questions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_quiz_questions_updated_at BEFORE UPDATE ON public.quiz_questions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_quiz_progress update_user_quiz_progress_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_quiz_progress_updated_at BEFORE UPDATE ON public.user_quiz_progress FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_stats update_user_stats_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_stats_updated_at BEFORE UPDATE ON public.user_stats FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: beast_mode_attempts beast_mode_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_attempts
    ADD CONSTRAINT beast_mode_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: beast_mode_attempts beast_mode_attempts_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_attempts
    ADD CONSTRAINT beast_mode_attempts_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: beast_mode_cooldowns beast_mode_cooldowns_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_cooldowns
    ADD CONSTRAINT beast_mode_cooldowns_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: beast_mode_cooldowns beast_mode_cooldowns_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beast_mode_cooldowns
    ADD CONSTRAINT beast_mode_cooldowns_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: citations citations_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citations
    ADD CONSTRAINT citations_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.word_timeline_events(id) ON DELETE CASCADE;


--
-- Name: floor_boss_scenarios floor_boss_scenarios_correct_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floor_boss_scenarios
    ADD CONSTRAINT floor_boss_scenarios_correct_word_id_fkey FOREIGN KEY (correct_word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: floor_boss_scenarios floor_boss_scenarios_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floor_boss_scenarios
    ADD CONSTRAINT floor_boss_scenarios_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(id) ON DELETE CASCADE;


--
-- Name: floors floors_map_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_map_id_fkey FOREIGN KEY (map_id) REFERENCES public.maps(id) ON DELETE CASCADE;


--
-- Name: purchases purchases_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: purchases purchases_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quiz_materials quiz_materials_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_materials
    ADD CONSTRAINT quiz_materials_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: quiz_questions quiz_questions_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: quizzes quizzes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quizzes quizzes_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: silk_transactions silk_transactions_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.silk_transactions
    ADD CONSTRAINT silk_transactions_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id) ON DELETE CASCADE;


--
-- Name: silk_transactions silk_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.silk_transactions
    ADD CONSTRAINT silk_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: story_comprehension_questions story_comprehension_questions_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_comprehension_questions
    ADD CONSTRAINT story_comprehension_questions_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


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
-- Name: user_floor_boss_attempts user_floor_boss_attempts_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_floor_boss_attempts
    ADD CONSTRAINT user_floor_boss_attempts_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(id) ON DELETE CASCADE;


--
-- Name: user_floor_boss_attempts user_floor_boss_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_floor_boss_attempts
    ADD CONSTRAINT user_floor_boss_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_map_progress user_map_progress_map_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_map_progress
    ADD CONSTRAINT user_map_progress_map_id_fkey FOREIGN KEY (map_id) REFERENCES public.maps(id) ON DELETE CASCADE;


--
-- Name: user_map_progress user_map_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_map_progress
    ADD CONSTRAINT user_map_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_quiz_progress user_quiz_progress_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_quiz_progress
    ADD CONSTRAINT user_quiz_progress_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: user_room_unlocks user_room_unlocks_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_room_unlocks
    ADD CONSTRAINT user_room_unlocks_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: user_room_unlocks user_room_unlocks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_room_unlocks
    ADD CONSTRAINT user_room_unlocks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_story_study_attempts user_story_study_attempts_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_attempts
    ADD CONSTRAINT user_story_study_attempts_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.story_comprehension_questions(id) ON DELETE CASCADE;


--
-- Name: user_story_study_attempts user_story_study_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_attempts
    ADD CONSTRAINT user_story_study_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_story_study_attempts user_story_study_attempts_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_attempts
    ADD CONSTRAINT user_story_study_attempts_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: user_story_study_progress user_story_study_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_progress
    ADD CONSTRAINT user_story_study_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_story_study_progress user_story_study_progress_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_story_study_progress
    ADD CONSTRAINT user_story_study_progress_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


--
-- Name: user_word_definitions user_word_definitions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_word_definitions
    ADD CONSTRAINT user_word_definitions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_word_definitions user_word_definitions_word_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_word_definitions
    ADD CONSTRAINT user_word_definitions_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocab_entries(id) ON DELETE CASCADE;


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

\unrestrict TSTH1u4fj81NmlEa0a762FKs9bHnYeG0z14reeu9ikddiCycF06Xl0aUPiNFbtx

