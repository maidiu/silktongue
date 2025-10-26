-- Table: public.causal_tags

-- DROP TABLE IF EXISTS public.causal_tags;

CREATE TABLE IF NOT EXISTS public.causal_tags
(
    id integer NOT NULL DEFAULT nextval('causal_tags_id_seq'::regclass),
    tag_name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT causal_tags_pkey PRIMARY KEY (id),
    CONSTRAINT causal_tags_tag_name_key UNIQUE (tag_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.causal_tags
    OWNER to postgres;


    -- Table: public.citations

-- DROP TABLE IF EXISTS public.citations;

CREATE TABLE IF NOT EXISTS public.citations
(
    id integer NOT NULL DEFAULT nextval('citations_id_seq'::regclass),
    event_id integer NOT NULL,
    source text COLLATE pg_catalog."default" NOT NULL,
    url text COLLATE pg_catalog."default",
    quote text COLLATE pg_catalog."default",
    added_at timestamp with time zone DEFAULT now(),
    CONSTRAINT citations_pkey PRIMARY KEY (id),
    CONSTRAINT citations_event_id_fkey FOREIGN KEY (event_id)
        REFERENCES public.word_timeline_events (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.citations
    OWNER to postgres;
-- Index: idx_citations_event

-- DROP INDEX IF EXISTS public.idx_citations_event;

CREATE INDEX IF NOT EXISTS idx_citations_event
    ON public.citations USING btree
    (event_id ASC NULLS LAST)
    TABLESPACE pg_default;


    -- Table: public.derivations

-- DROP TABLE IF EXISTS public.derivations;

CREATE TABLE IF NOT EXISTS public.derivations
(
    id integer NOT NULL DEFAULT nextval('derivations_id_seq'::regclass),
    parent_vocab_id integer NOT NULL,
    child_vocab_id integer NOT NULL,
    relation_type derivation_relation_type NOT NULL,
    notes text COLLATE pg_catalog."default",
    CONSTRAINT derivations_pkey PRIMARY KEY (id),
    CONSTRAINT derivations_parent_vocab_id_child_vocab_id_relation_type_key UNIQUE (parent_vocab_id, child_vocab_id, relation_type),
    CONSTRAINT derivations_check CHECK (parent_vocab_id <> child_vocab_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.derivations
    OWNER to postgres;
-- Index: idx_derivations_child

-- DROP INDEX IF EXISTS public.idx_derivations_child;

CREATE INDEX IF NOT EXISTS idx_derivations_child
    ON public.derivations USING btree
    (child_vocab_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_derivations_parent

-- DROP INDEX IF EXISTS public.idx_derivations_parent;

CREATE INDEX IF NOT EXISTS idx_derivations_parent
    ON public.derivations USING btree
    (parent_vocab_id ASC NULLS LAST)
    TABLESPACE pg_default;



    -- Table: public.purchases

-- DROP TABLE IF EXISTS public.purchases;

CREATE TABLE IF NOT EXISTS public.purchases
(
    id integer NOT NULL DEFAULT nextval('purchases_id_seq'::regclass),
    user_id integer,
    token_id integer,
    purchased_at timestamp without time zone DEFAULT now(),
    CONSTRAINT purchases_pkey PRIMARY KEY (id),
    CONSTRAINT purchases_token_id_fkey FOREIGN KEY (token_id)
        REFERENCES public.tokens (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT purchases_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.purchases
    OWNER to postgres;
-- Index: idx_purchases_user_id

-- DROP INDEX IF EXISTS public.idx_purchases_user_id;

CREATE INDEX IF NOT EXISTS idx_purchases_user_id
    ON public.purchases USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;


    -- Table: public.quiz_attempts

-- DROP TABLE IF EXISTS public.quiz_attempts;

CREATE TABLE IF NOT EXISTS public.quiz_attempts
(
    id integer NOT NULL DEFAULT nextval('quiz_attempts_id_seq'::regclass),
    quiz_id integer,
    level integer NOT NULL,
    is_correct boolean,
    attempted_at timestamp without time zone DEFAULT now(),
    CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id),
    CONSTRAINT quiz_attempts_level_check CHECK (level >= 1 AND level <= 6)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.quiz_attempts
    OWNER to postgres;
-- Index: idx_attempts_quiz_id

-- DROP INDEX IF EXISTS public.idx_attempts_quiz_id;

CREATE INDEX IF NOT EXISTS idx_attempts_quiz_id
    ON public.quiz_attempts USING btree
    (quiz_id ASC NULLS LAST)
    TABLESPACE pg_default;


    -- Table: public.quiz_materials

-- DROP TABLE IF EXISTS public.quiz_materials;

CREATE TABLE IF NOT EXISTS public.quiz_materials
(
    id integer NOT NULL DEFAULT nextval('quiz_materials_id_seq'::regclass),
    word_id integer,
    level integer,
    question_type text COLLATE pg_catalog."default",
    prompt text COLLATE pg_catalog."default",
    options jsonb,
    correct_answer text COLLATE pg_catalog."default",
    variant_data jsonb,
    reward_amount integer DEFAULT 10,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT quiz_materials_pkey PRIMARY KEY (id),
    CONSTRAINT quiz_materials_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT quiz_materials_question_type_check CHECK (question_type = ANY (ARRAY['spelling'::text, 'typing'::text, 'definition'::text, 'synonym'::text, 'antonym'::text, 'story'::text, 'story_reorder'::text, 'syn_ant_sort'::text])),
    CONSTRAINT quiz_materials_level_check CHECK (level >= 1 AND level <= 6)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.quiz_materials
    OWNER to postgres;
-- Index: idx_quiz_materials_word_level

-- DROP INDEX IF EXISTS public.idx_quiz_materials_word_level;

CREATE INDEX IF NOT EXISTS idx_quiz_materials_word_level
    ON public.quiz_materials USING btree
    (word_id ASC NULLS LAST, level ASC NULLS LAST)
    TABLESPACE pg_default;


    -- Table: public.quiz_questions

-- DROP TABLE IF EXISTS public.quiz_questions;

CREATE TABLE IF NOT EXISTS public.quiz_questions
(
    id integer NOT NULL DEFAULT nextval('quiz_questions_id_seq'::regclass),
    word_id integer,
    level integer NOT NULL,
    question_type text COLLATE pg_catalog."default" NOT NULL,
    prompt text COLLATE pg_catalog."default" NOT NULL,
    options jsonb,
    correct_answer text COLLATE pg_catalog."default",
    correct_answers jsonb,
    variant_data jsonb,
    reward_amount integer DEFAULT 10,
    difficulty text COLLATE pg_catalog."default" DEFAULT 'normal'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT quiz_questions_pkey PRIMARY KEY (id),
    CONSTRAINT quiz_questions_word_id_level_key UNIQUE (word_id, level),
    CONSTRAINT quiz_questions_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.quiz_questions
    OWNER to postgres;
-- Index: idx_quiz_questions_level

-- DROP INDEX IF EXISTS public.idx_quiz_questions_level;

CREATE INDEX IF NOT EXISTS idx_quiz_questions_level
    ON public.quiz_questions USING btree
    (level ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_quiz_questions_word_id

-- DROP INDEX IF EXISTS public.idx_quiz_questions_word_id;

CREATE INDEX IF NOT EXISTS idx_quiz_questions_word_id
    ON public.quiz_questions USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- Trigger: update_quiz_questions_updated_at

-- DROP TRIGGER IF EXISTS update_quiz_questions_updated_at ON public.quiz_questions;

CREATE OR REPLACE TRIGGER update_quiz_questions_updated_at
    BEFORE UPDATE 
    ON public.quiz_questions
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();


    -- Table: public.quizzes

-- DROP TABLE IF EXISTS public.quizzes;

CREATE TABLE IF NOT EXISTS public.quizzes
(
    id integer NOT NULL DEFAULT nextval('quizzes_id_seq'::regclass),
    user_id integer,
    word_id integer,
    current_level integer DEFAULT 1,
    is_active boolean DEFAULT true,
    started_at timestamp without time zone DEFAULT now(),
    completed_at timestamp without time zone,
    hard_mode boolean DEFAULT false,
    wager_amount integer DEFAULT 0,
    hard_mode_completed boolean DEFAULT false,
    CONSTRAINT quizzes_pkey PRIMARY KEY (id),
    CONSTRAINT quizzes_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT quizzes_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT quizzes_current_level_check CHECK (current_level >= 1 AND current_level <= 5),
    CONSTRAINT quizzes_wager_amount_check CHECK (wager_amount >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.quizzes
    OWNER to postgres;
-- Index: idx_quizzes_user_id

-- DROP INDEX IF EXISTS public.idx_quizzes_user_id;

CREATE INDEX IF NOT EXISTS idx_quizzes_user_id
    ON public.quizzes USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_quizzes_word_id

-- DROP INDEX IF EXISTS public.idx_quizzes_word_id;

CREATE INDEX IF NOT EXISTS idx_quizzes_word_id
    ON public.quizzes USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


    -- Table: public.root_families

-- DROP TABLE IF EXISTS public.root_families;

CREATE TABLE IF NOT EXISTS public.root_families
(
    id integer NOT NULL DEFAULT nextval('root_families_id_seq'::regclass),
    root_word text COLLATE pg_catalog."default" NOT NULL,
    language text COLLATE pg_catalog."default" NOT NULL,
    gloss text COLLATE pg_catalog."default",
    CONSTRAINT root_families_pkey PRIMARY KEY (id),
    CONSTRAINT root_families_root_word_language_key UNIQUE (root_word, language)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.root_families
    OWNER to postgres;


-- Table: public.semantic_domains

-- DROP TABLE IF EXISTS public.semantic_domains;

CREATE TABLE IF NOT EXISTS public.semantic_domains
(
    id integer NOT NULL DEFAULT nextval('semantic_domains_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT semantic_domains_pkey PRIMARY KEY (id),
    CONSTRAINT semantic_domains_name_key UNIQUE (name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.semantic_domains
    OWNER to postgres;


-- Table: public.silk_transactions

-- DROP TABLE IF EXISTS public.silk_transactions;

CREATE TABLE IF NOT EXISTS public.silk_transactions
(
    id integer NOT NULL DEFAULT nextval('silk_transactions_id_seq'::regclass),
    user_id integer,
    quiz_id integer,
    amount integer NOT NULL,
    transaction_type text COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT silk_transactions_pkey PRIMARY KEY (id),
    CONSTRAINT silk_transactions_quiz_id_fkey FOREIGN KEY (quiz_id)
        REFERENCES public.quizzes (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT silk_transactions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT silk_transactions_transaction_type_check CHECK (transaction_type = ANY (ARRAY['earn'::text, 'spend'::text, 'wager_win'::text, 'wager_loss'::text]))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.silk_transactions
    OWNER to postgres;


-- Table: public.timeline_event_tags

-- DROP TABLE IF EXISTS public.timeline_event_tags;

CREATE TABLE IF NOT EXISTS public.timeline_event_tags
(
    event_id integer NOT NULL,
    tag_id integer NOT NULL,
    CONSTRAINT timeline_event_tags_pkey PRIMARY KEY (event_id, tag_id),
    CONSTRAINT timeline_event_tags_event_id_fkey FOREIGN KEY (event_id)
        REFERENCES public.word_timeline_events (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT timeline_event_tags_tag_id_fkey FOREIGN KEY (tag_id)
        REFERENCES public.causal_tags (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.timeline_event_tags
    OWNER to postgres;
-- Index: idx_event_tags_event

-- DROP INDEX IF EXISTS public.idx_event_tags_event;

CREATE INDEX IF NOT EXISTS idx_event_tags_event
    ON public.timeline_event_tags USING btree
    (event_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_event_tags_tag

-- DROP INDEX IF EXISTS public.idx_event_tags_tag;

CREATE INDEX IF NOT EXISTS idx_event_tags_tag
    ON public.timeline_event_tags USING btree
    (tag_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.tokens

-- DROP TABLE IF EXISTS public.tokens;

CREATE TABLE IF NOT EXISTS public.tokens
(
    id integer NOT NULL DEFAULT nextval('tokens_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    silk_cost integer NOT NULL,
    image_url text COLLATE pg_catalog."default",
    CONSTRAINT tokens_pkey PRIMARY KEY (id),
    CONSTRAINT tokens_silk_cost_check CHECK (silk_cost >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tokens
    OWNER to postgres;


-- Table: public.user_quiz_progress

-- DROP TABLE IF EXISTS public.user_quiz_progress;

CREATE TABLE IF NOT EXISTS public.user_quiz_progress
(
    id integer NOT NULL DEFAULT nextval('user_quiz_progress_id_seq'::regclass),
    user_id integer,
    word_id integer,
    current_level integer DEFAULT 1,
    max_level_reached integer DEFAULT 1,
    health_remaining integer DEFAULT 5,
    silk_earned integer DEFAULT 0,
    completed_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_quiz_progress_pkey PRIMARY KEY (id),
    CONSTRAINT user_quiz_progress_user_id_word_id_key UNIQUE (user_id, word_id),
    CONSTRAINT user_quiz_progress_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_quiz_progress
    OWNER to postgres;
-- Index: idx_user_quiz_progress_user_word

-- DROP INDEX IF EXISTS public.idx_user_quiz_progress_user_word;

CREATE INDEX IF NOT EXISTS idx_user_quiz_progress_user_word
    ON public.user_quiz_progress USING btree
    (user_id ASC NULLS LAST, word_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- Trigger: update_user_quiz_progress_updated_at

-- DROP TRIGGER IF EXISTS update_user_quiz_progress_updated_at ON public.user_quiz_progress;

CREATE OR REPLACE TRIGGER update_user_quiz_progress_updated_at
    BEFORE UPDATE 
    ON public.user_quiz_progress
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();


-- Table: public.user_stats

-- DROP TABLE IF EXISTS public.user_stats;

CREATE TABLE IF NOT EXISTS public.user_stats
(
    id integer NOT NULL DEFAULT nextval('user_stats_id_seq'::regclass),
    user_id integer,
    silk_balance integer DEFAULT 0,
    words_mastered integer DEFAULT 0,
    quizzes_completed integer DEFAULT 0,
    total_health_lost integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_stats_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_stats
    OWNER to postgres;

-- Trigger: update_user_stats_updated_at

-- DROP TRIGGER IF EXISTS update_user_stats_updated_at ON public.user_stats;

CREATE OR REPLACE TRIGGER update_user_stats_updated_at
    BEFORE UPDATE 
    ON public.user_stats
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();


-- Table: public.users

-- DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS public.users
(
    id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    username text COLLATE pg_catalog."default" NOT NULL,
    password_hash text COLLATE pg_catalog."default" NOT NULL,
    silk_balance integer DEFAULT 0,
    health_points integer DEFAULT 5,
    last_health_reset timestamp without time zone DEFAULT now(),
    words_learned integer DEFAULT 0,
    words_mastered integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    is_admin boolean DEFAULT false,
    max_health_points integer DEFAULT 3,
    avatar_config jsonb DEFAULT '{"body": "hornet", "mask": "hornet", "wings": "silk", "weapon": "needle", "effects": ["sparkle"], "accentColor": "#ff6b6b", "primaryColor": "#2d1b2d", "secondaryColor": "#4a2c4a"}'::jsonb,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_username_key UNIQUE (username),
    CONSTRAINT users_silk_balance_check CHECK (silk_balance >= 0),
    CONSTRAINT users_health_points_check CHECK (health_points >= 0),
    CONSTRAINT users_max_health_points_check CHECK (max_health_points >= 3 AND max_health_points <= 6)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;


-- Table: public.vocab_domain_links

-- DROP TABLE IF EXISTS public.vocab_domain_links;

CREATE TABLE IF NOT EXISTS public.vocab_domain_links
(
    vocab_id integer NOT NULL,
    domain_id integer NOT NULL,
    CONSTRAINT vocab_domain_links_pkey PRIMARY KEY (vocab_id, domain_id),
    CONSTRAINT vocab_domain_links_domain_id_fkey FOREIGN KEY (domain_id)
        REFERENCES public.semantic_domains (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.vocab_domain_links
    OWNER to postgres;
-- Index: idx_vocab_domain_dom

-- DROP INDEX IF EXISTS public.idx_vocab_domain_dom;

CREATE INDEX IF NOT EXISTS idx_vocab_domain_dom
    ON public.vocab_domain_links USING btree
    (domain_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_vocab_domain_vocab

-- DROP INDEX IF EXISTS public.idx_vocab_domain_vocab;

CREATE INDEX IF NOT EXISTS idx_vocab_domain_vocab
    ON public.vocab_domain_links USING btree
    (vocab_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.vocab_entries

-- DROP TABLE IF EXISTS public.vocab_entries;

CREATE TABLE IF NOT EXISTS public.vocab_entries
(
    id integer NOT NULL DEFAULT nextval('vocab_entries_id_seq'::regclass),
    word text COLLATE pg_catalog."default" NOT NULL,
    part_of_speech text COLLATE pg_catalog."default",
    modern_definition text COLLATE pg_catalog."default",
    usage_example text COLLATE pg_catalog."default",
    synonyms text[] COLLATE pg_catalog."default",
    antonyms text[] COLLATE pg_catalog."default",
    collocations jsonb DEFAULT '{}'::jsonb,
    french_equivalent text COLLATE pg_catalog."default",
    russian_equivalent text COLLATE pg_catalog."default",
    cefr_level text COLLATE pg_catalog."default",
    pronunciation text COLLATE pg_catalog."default",
    is_mastered boolean DEFAULT false,
    date_added timestamp without time zone DEFAULT now(),
    story_text text COLLATE pg_catalog."default",
    contrastive_opening text COLLATE pg_catalog."default",
    structural_analysis text COLLATE pg_catalog."default",
    common_collocations text[] COLLATE pg_catalog."default",
    metadata jsonb,
    definitions jsonb,
    variant_forms text[] COLLATE pg_catalog."default",
    semantic_field text[] COLLATE pg_catalog."default",
    english_synonyms text[] COLLATE pg_catalog."default",
    english_antonyms text[] COLLATE pg_catalog."default",
    french_synonyms text[] COLLATE pg_catalog."default",
    french_root_cognates text[] COLLATE pg_catalog."default",
    russian_synonyms text[] COLLATE pg_catalog."default",
    russian_root_cognates text[] COLLATE pg_catalog."default",
    common_phrases text[] COLLATE pg_catalog."default",
    story_intro text COLLATE pg_catalog."default",
    learning_status character varying(20) COLLATE pg_catalog."default" DEFAULT 'unmastered'::character varying,
    CONSTRAINT vocab_entries_pkey PRIMARY KEY (id),
    CONSTRAINT vocab_entries_word_key UNIQUE (word),
    CONSTRAINT vocab_entries_learning_status_check CHECK (learning_status::text = ANY (ARRAY['unmastered'::character varying, 'learned'::character varying, 'mastered'::character varying]::text[]))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.vocab_entries
    OWNER to postgres;
-- Index: idx_vocab_entries_status

-- DROP INDEX IF EXISTS public.idx_vocab_entries_status;

CREATE INDEX IF NOT EXISTS idx_vocab_entries_status
    ON public.vocab_entries USING btree
    (learning_status COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: vocab_definitions_idx

-- DROP INDEX IF EXISTS public.vocab_definitions_idx;

CREATE INDEX IF NOT EXISTS vocab_definitions_idx
    ON public.vocab_entries USING gin
    (definitions)
    TABLESPACE pg_default;
-- Index: vocab_long_story_idx

-- DROP INDEX IF EXISTS public.vocab_long_story_idx;

CREATE INDEX IF NOT EXISTS vocab_long_story_idx
    ON public.vocab_entries USING gin
    (to_tsvector('english'::regconfig, story_intro))
    TABLESPACE pg_default;


-- Table: public.word_relations

-- DROP TABLE IF EXISTS public.word_relations;

CREATE TABLE IF NOT EXISTS public.word_relations
(
    id integer NOT NULL DEFAULT nextval('word_relations_id_seq'::regclass),
    source_id integer NOT NULL,
    target_id integer NOT NULL,
    relation_type word_relation_type NOT NULL,
    note text COLLATE pg_catalog."default",
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT word_relations_pkey PRIMARY KEY (id),
    CONSTRAINT word_relations_source_id_target_id_relation_type_key UNIQUE (source_id, target_id, relation_type),
    CONSTRAINT word_relations_check CHECK (source_id <> target_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.word_relations
    OWNER to postgres;
-- Index: idx_word_relations_source

-- DROP INDEX IF EXISTS public.idx_word_relations_source;

CREATE INDEX IF NOT EXISTS idx_word_relations_source
    ON public.word_relations USING btree
    (source_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_word_relations_target

-- DROP INDEX IF EXISTS public.idx_word_relations_target;

CREATE INDEX IF NOT EXISTS idx_word_relations_target
    ON public.word_relations USING btree
    (target_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_word_relations_type

-- DROP INDEX IF EXISTS public.idx_word_relations_type;

CREATE INDEX IF NOT EXISTS idx_word_relations_type
    ON public.word_relations USING btree
    (relation_type ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.word_root_links

-- DROP TABLE IF EXISTS public.word_root_links;

CREATE TABLE IF NOT EXISTS public.word_root_links
(
    vocab_id integer NOT NULL,
    root_id integer NOT NULL,
    relation_description text COLLATE pg_catalog."default",
    CONSTRAINT word_root_links_pkey PRIMARY KEY (vocab_id, root_id),
    CONSTRAINT word_root_links_root_id_fkey FOREIGN KEY (root_id)
        REFERENCES public.root_families (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.word_root_links
    OWNER to postgres;
-- Index: idx_word_root_links_root

-- DROP INDEX IF EXISTS public.idx_word_root_links_root;

CREATE INDEX IF NOT EXISTS idx_word_root_links_root
    ON public.word_root_links USING btree
    (root_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_word_root_links_vocab

-- DROP INDEX IF EXISTS public.idx_word_root_links_vocab;

CREATE INDEX IF NOT EXISTS idx_word_root_links_vocab
    ON public.word_root_links USING btree
    (vocab_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.word_timeline_events

-- DROP TABLE IF EXISTS public.word_timeline_events;

CREATE TABLE IF NOT EXISTS public.word_timeline_events
(
    id integer NOT NULL DEFAULT nextval('word_timeline_events_id_seq'::regclass),
    vocab_id integer NOT NULL,
    century integer NOT NULL,
    exact_date text COLLATE pg_catalog."default",
    language_stage text COLLATE pg_catalog."default",
    region text COLLATE pg_catalog."default",
    semantic_focus text COLLATE pg_catalog."default",
    event_text text COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    sibling_words text[] COLLATE pg_catalog."default",
    context text COLLATE pg_catalog."default",
    CONSTRAINT word_timeline_events_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.word_timeline_events
    OWNER to postgres;
-- Index: idx_timeline_century

-- DROP INDEX IF EXISTS public.idx_timeline_century;

CREATE INDEX IF NOT EXISTS idx_timeline_century
    ON public.word_timeline_events USING btree
    (century ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_timeline_lang

-- DROP INDEX IF EXISTS public.idx_timeline_lang;

CREATE INDEX IF NOT EXISTS idx_timeline_lang
    ON public.word_timeline_events USING btree
    (language_stage COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_timeline_semantic

-- DROP INDEX IF EXISTS public.idx_timeline_semantic;

CREATE INDEX IF NOT EXISTS idx_timeline_semantic
    ON public.word_timeline_events USING btree
    (semantic_focus COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_timeline_vocab

-- DROP INDEX IF EXISTS public.idx_timeline_vocab;

CREATE INDEX IF NOT EXISTS idx_timeline_vocab
    ON public.word_timeline_events USING btree
    (vocab_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.beast_mode_attempts

-- DROP TABLE IF EXISTS public.beast_mode_attempts;

CREATE TABLE IF NOT EXISTS public.beast_mode_attempts
(
    id integer NOT NULL DEFAULT nextval('beast_mode_attempts_id_seq'::regclass),
    user_id integer,
    word_id integer,
    wager_amount integer NOT NULL,
    success boolean NOT NULL,
    silk_earned integer DEFAULT 0,
    attempted_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT beast_mode_attempts_pkey PRIMARY KEY (id),
    CONSTRAINT beast_mode_attempts_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT beast_mode_attempts_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT beast_mode_attempts_wager_amount_check CHECK (wager_amount > 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.beast_mode_attempts
    OWNER to postgres;
-- Index: idx_beast_attempts_user

-- DROP INDEX IF EXISTS public.idx_beast_attempts_user;

CREATE INDEX IF NOT EXISTS idx_beast_attempts_user
    ON public.beast_mode_attempts USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_beast_attempts_word

-- DROP INDEX IF EXISTS public.idx_beast_attempts_word;

CREATE INDEX IF NOT EXISTS idx_beast_attempts_word
    ON public.beast_mode_attempts USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- Trigger: update_beast_mode_attempts_updated_at

-- DROP TRIGGER IF EXISTS update_beast_mode_attempts_updated_at ON public.beast_mode_attempts;

CREATE OR REPLACE TRIGGER update_beast_mode_attempts_updated_at
    BEFORE UPDATE 
    ON public.beast_mode_attempts
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();


-- Table: public.beast_mode_cooldowns

-- DROP TABLE IF EXISTS public.beast_mode_cooldowns;

CREATE TABLE IF NOT EXISTS public.beast_mode_cooldowns
(
    id integer NOT NULL DEFAULT nextval('beast_mode_cooldowns_id_seq'::regclass),
    user_id integer,
    word_id integer,
    last_attempt timestamp with time zone DEFAULT now(),
    cooldown_until timestamp with time zone DEFAULT (now() + '01:00:00'::interval),
    CONSTRAINT beast_mode_cooldowns_pkey PRIMARY KEY (id),
    CONSTRAINT beast_mode_cooldowns_user_id_word_id_key UNIQUE (user_id, word_id),
    CONSTRAINT beast_mode_cooldowns_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT beast_mode_cooldowns_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.beast_mode_cooldowns
    OWNER to postgres;
-- Index: idx_beast_cooldowns_user

-- DROP INDEX IF EXISTS public.idx_beast_cooldowns_user;

CREATE INDEX IF NOT EXISTS idx_beast_cooldowns_user
    ON public.beast_mode_cooldowns USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_beast_cooldowns_word

-- DROP INDEX IF EXISTS public.idx_beast_cooldowns_word;

CREATE INDEX IF NOT EXISTS idx_beast_cooldowns_word
    ON public.beast_mode_cooldowns USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.floor_boss_scenarios

-- DROP TABLE IF EXISTS public.floor_boss_scenarios;

CREATE TABLE IF NOT EXISTS public.floor_boss_scenarios
(
    id integer NOT NULL DEFAULT nextval('floor_boss_scenarios_id_seq'::regclass),
    floor_id integer,
    scenario_text text COLLATE pg_catalog."default" NOT NULL,
    correct_word_id integer,
    difficulty_level integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT floor_boss_scenarios_pkey PRIMARY KEY (id),
    CONSTRAINT floor_boss_scenarios_correct_word_id_fkey FOREIGN KEY (correct_word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT floor_boss_scenarios_floor_id_fkey FOREIGN KEY (floor_id)
        REFERENCES public.floors (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.floor_boss_scenarios
    OWNER to postgres;
-- Index: idx_floor_boss_scenarios_floor_id

-- DROP INDEX IF EXISTS public.idx_floor_boss_scenarios_floor_id;

CREATE INDEX IF NOT EXISTS idx_floor_boss_scenarios_floor_id
    ON public.floor_boss_scenarios USING btree
    (floor_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.floors

-- DROP TABLE IF EXISTS public.floors;

CREATE TABLE IF NOT EXISTS public.floors
(
    id integer NOT NULL DEFAULT nextval('floors_id_seq'::regclass),
    map_id integer,
    floor_number integer NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    unlock_requirement text COLLATE pg_catalog."default",
    boss_challenge_type text COLLATE pg_catalog."default" DEFAULT 'scenario_typing'::text,
    silk_reward integer DEFAULT 100,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT floors_pkey PRIMARY KEY (id),
    CONSTRAINT floors_map_id_floor_number_key UNIQUE (map_id, floor_number),
    CONSTRAINT floors_map_id_fkey FOREIGN KEY (map_id)
        REFERENCES public.maps (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.floors
    OWNER to postgres;
-- Index: idx_floors_map_id

-- DROP INDEX IF EXISTS public.idx_floors_map_id;

CREATE INDEX IF NOT EXISTS idx_floors_map_id
    ON public.floors USING btree
    (map_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.maps

-- DROP TABLE IF EXISTS public.maps;

CREATE TABLE IF NOT EXISTS public.maps
(
    id integer NOT NULL DEFAULT nextval('maps_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    total_floors integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT maps_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.maps
    OWNER to postgres;


-- Table: public.rooms

-- DROP TABLE IF EXISTS public.rooms;

CREATE TABLE IF NOT EXISTS public.rooms
(
    id integer NOT NULL DEFAULT nextval('rooms_id_seq'::regclass),
    floor_id integer,
    word_id integer,
    room_number integer NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    silk_cost integer DEFAULT 50,
    silk_reward integer DEFAULT 25,
    is_boss_room boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT rooms_pkey PRIMARY KEY (id),
    CONSTRAINT rooms_floor_id_room_number_key UNIQUE (floor_id, room_number),
    CONSTRAINT rooms_floor_id_fkey FOREIGN KEY (floor_id)
        REFERENCES public.floors (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT rooms_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.rooms
    OWNER to postgres;
-- Index: idx_rooms_floor_id

-- DROP INDEX IF EXISTS public.idx_rooms_floor_id;

CREATE INDEX IF NOT EXISTS idx_rooms_floor_id
    ON public.rooms USING btree
    (floor_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_rooms_word_id

-- DROP INDEX IF EXISTS public.idx_rooms_word_id;

CREATE INDEX IF NOT EXISTS idx_rooms_word_id
    ON public.rooms USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.story_comprehension_questions

-- DROP TABLE IF EXISTS public.story_comprehension_questions;

CREATE TABLE IF NOT EXISTS public.story_comprehension_questions
(
    id integer NOT NULL DEFAULT nextval('story_comprehension_questions_id_seq'::regclass),
    word_id integer NOT NULL,
    century character varying(10) COLLATE pg_catalog."default" NOT NULL,
    question text COLLATE pg_catalog."default" NOT NULL,
    options jsonb NOT NULL,
    correct_answer character varying(255) COLLATE pg_catalog."default" NOT NULL,
    explanation text COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT story_comprehension_questions_pkey PRIMARY KEY (id),
    CONSTRAINT story_comprehension_questions_word_id_century_key UNIQUE (word_id, century),
    CONSTRAINT story_comprehension_questions_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.story_comprehension_questions
    OWNER to postgres;
-- Index: idx_story_comprehension_word_id

-- DROP INDEX IF EXISTS public.idx_story_comprehension_word_id;

CREATE INDEX IF NOT EXISTS idx_story_comprehension_word_id
    ON public.story_comprehension_questions USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_floor_boss_attempts

-- DROP TABLE IF EXISTS public.user_floor_boss_attempts;

CREATE TABLE IF NOT EXISTS public.user_floor_boss_attempts
(
    id integer NOT NULL DEFAULT nextval('user_floor_boss_attempts_id_seq'::regclass),
    user_id integer,
    floor_id integer,
    scenarios_presented jsonb,
    user_responses jsonb,
    correct_count integer DEFAULT 0,
    total_scenarios integer DEFAULT 0,
    success boolean DEFAULT false,
    silk_earned integer DEFAULT 0,
    attempted_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    CONSTRAINT user_floor_boss_attempts_pkey PRIMARY KEY (id),
    CONSTRAINT user_floor_boss_attempts_floor_id_fkey FOREIGN KEY (floor_id)
        REFERENCES public.floors (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_floor_boss_attempts_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_floor_boss_attempts
    OWNER to postgres;
-- Index: idx_user_floor_boss_attempts_floor_id

-- DROP INDEX IF EXISTS public.idx_user_floor_boss_attempts_floor_id;

CREATE INDEX IF NOT EXISTS idx_user_floor_boss_attempts_floor_id
    ON public.user_floor_boss_attempts USING btree
    (floor_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_user_floor_boss_attempts_user_id

-- DROP INDEX IF EXISTS public.idx_user_floor_boss_attempts_user_id;

CREATE INDEX IF NOT EXISTS idx_user_floor_boss_attempts_user_id
    ON public.user_floor_boss_attempts USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_map_progress

-- DROP TABLE IF EXISTS public.user_map_progress;

CREATE TABLE IF NOT EXISTS public.user_map_progress
(
    id integer NOT NULL DEFAULT nextval('user_map_progress_id_seq'::regclass),
    user_id integer,
    map_id integer,
    current_floor integer DEFAULT 1,
    current_room integer DEFAULT 1,
    floors_completed integer DEFAULT 0,
    total_silk_spent integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_map_progress_pkey PRIMARY KEY (id),
    CONSTRAINT user_map_progress_user_id_map_id_key UNIQUE (user_id, map_id),
    CONSTRAINT user_map_progress_map_id_fkey FOREIGN KEY (map_id)
        REFERENCES public.maps (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_map_progress_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_map_progress
    OWNER to postgres;
-- Index: idx_user_map_progress_user_id

-- DROP INDEX IF EXISTS public.idx_user_map_progress_user_id;

CREATE INDEX IF NOT EXISTS idx_user_map_progress_user_id
    ON public.user_map_progress USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_room_unlocks

-- DROP TABLE IF EXISTS public.user_room_unlocks;

CREATE TABLE IF NOT EXISTS public.user_room_unlocks
(
    id integer NOT NULL DEFAULT nextval('user_room_unlocks_id_seq'::regclass),
    user_id integer,
    room_id integer,
    unlocked_at timestamp with time zone DEFAULT now(),
    silk_spent integer DEFAULT 0,
    silk_earned integer DEFAULT 0,
    completed_at timestamp with time zone,
    CONSTRAINT user_room_unlocks_pkey PRIMARY KEY (id),
    CONSTRAINT user_room_unlocks_user_id_room_id_key UNIQUE (user_id, room_id),
    CONSTRAINT user_room_unlocks_room_id_fkey FOREIGN KEY (room_id)
        REFERENCES public.rooms (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_room_unlocks_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_room_unlocks
    OWNER to postgres;
-- Index: idx_user_room_unlocks_room_id

-- DROP INDEX IF EXISTS public.idx_user_room_unlocks_room_id;

CREATE INDEX IF NOT EXISTS idx_user_room_unlocks_room_id
    ON public.user_room_unlocks USING btree
    (room_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_user_room_unlocks_user_id

-- DROP INDEX IF EXISTS public.idx_user_room_unlocks_user_id;

CREATE INDEX IF NOT EXISTS idx_user_room_unlocks_user_id
    ON public.user_room_unlocks USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_story_study_attempts

-- DROP TABLE IF EXISTS public.user_story_study_attempts;

CREATE TABLE IF NOT EXISTS public.user_story_study_attempts
(
    id integer NOT NULL DEFAULT nextval('user_story_study_attempts_id_seq'::regclass),
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    question_id integer NOT NULL,
    user_answer character varying(255) COLLATE pg_catalog."default" NOT NULL,
    is_correct boolean NOT NULL,
    attempted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_story_study_attempts_pkey PRIMARY KEY (id),
    CONSTRAINT user_story_study_attempts_question_id_fkey FOREIGN KEY (question_id)
        REFERENCES public.story_comprehension_questions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_story_study_attempts_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_story_study_attempts_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_story_study_attempts
    OWNER to postgres;
-- Index: idx_user_story_study_attempts_user_id

-- DROP INDEX IF EXISTS public.idx_user_story_study_attempts_user_id;

CREATE INDEX IF NOT EXISTS idx_user_story_study_attempts_user_id
    ON public.user_story_study_attempts USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_user_story_study_attempts_word_id

-- DROP INDEX IF EXISTS public.idx_user_story_study_attempts_word_id;

CREATE INDEX IF NOT EXISTS idx_user_story_study_attempts_word_id
    ON public.user_story_study_attempts USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_story_study_progress

-- DROP TABLE IF EXISTS public.user_story_study_progress;

CREATE TABLE IF NOT EXISTS public.user_story_study_progress
(
    id integer NOT NULL DEFAULT nextval('user_story_study_progress_id_seq'::regclass),
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    story_completed boolean DEFAULT false,
    first_completion_at timestamp with time zone,
    last_studied_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    times_studied integer DEFAULT 0,
    total_silk_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_story_study_progress_pkey PRIMARY KEY (id),
    CONSTRAINT user_story_study_progress_user_id_word_id_key UNIQUE (user_id, word_id),
    CONSTRAINT user_story_study_progress_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_story_study_progress_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_story_study_progress
    OWNER to postgres;
-- Index: idx_user_story_study_progress_user_id

-- DROP INDEX IF EXISTS public.idx_user_story_study_progress_user_id;

CREATE INDEX IF NOT EXISTS idx_user_story_study_progress_user_id
    ON public.user_story_study_progress USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_user_story_study_progress_word_id

-- DROP INDEX IF EXISTS public.idx_user_story_study_progress_word_id;

CREATE INDEX IF NOT EXISTS idx_user_story_study_progress_word_id
    ON public.user_story_study_progress USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- Table: public.user_word_definitions

-- DROP TABLE IF EXISTS public.user_word_definitions;

CREATE TABLE IF NOT EXISTS public.user_word_definitions
(
    id integer NOT NULL DEFAULT nextval('user_word_definitions_id_seq'::regclass),
    user_id integer NOT NULL,
    word_id integer NOT NULL,
    initial_definition text COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_word_definitions_pkey PRIMARY KEY (id),
    CONSTRAINT user_word_definitions_user_id_word_id_key UNIQUE (user_id, word_id),
    CONSTRAINT user_word_definitions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_word_definitions_word_id_fkey FOREIGN KEY (word_id)
        REFERENCES public.vocab_entries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_word_definitions
    OWNER to postgres;
-- Index: idx_user_word_definitions_user_id

-- DROP INDEX IF EXISTS public.idx_user_word_definitions_user_id;

CREATE INDEX IF NOT EXISTS idx_user_word_definitions_user_id
    ON public.user_word_definitions USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_user_word_definitions_word_id

-- DROP INDEX IF EXISTS public.idx_user_word_definitions_word_id;

CREATE INDEX IF NOT EXISTS idx_user_word_definitions_word_id
    ON public.user_word_definitions USING btree
    (word_id ASC NULLS LAST)
    TABLESPACE pg_default;