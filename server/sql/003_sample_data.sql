-- Sample vocabulary data for testing
-- Run this file to populate the database with example entries

-- Insert sample causal tags
INSERT INTO causal_tags (tag_name, description) VALUES
  ('lexical_competition', 'Competition between words for semantic space'),
  ('moralization', 'Process of acquiring moral or ethical connotations'),
  ('printing_revolution', 'Changes driven by the advent of printing technology'),
  ('bureaucratic_expansion', 'Development related to administrative and governmental growth'),
  ('discursive_specialization', 'Narrowing of meaning within specific discourse communities')
ON CONFLICT (tag_name) DO NOTHING;

-- Sample Entry 1: "omit"
INSERT INTO vocab_entries (
  word, part_of_speech, modern_definition, usage_example,
  synonyms, antonyms, french_equivalent, russian_equivalent,
  cefr_level, pronunciation, story_text, contrastive_opening, structural_analysis,
  is_mastered, date_added
) VALUES (
  'omit',
  'verb',
  'to leave out, exclude intentionally or accidentally',
  'He omitted the crucial detail from his account.',
  ARRAY['exclude', 'leave out', 'skip'],
  ARRAY['include', 'add'],
  'omettre',
  'упускать',
  'B2',
  '/əˈmɪt/',
  'The word "omit" traveled from physical sending to textual exclusion.',
  'Today "omit" means to leave something out. But in 1st-century Rome, mittere meant simply "to send" — and omittere meant "to send away" or "to let go." How did sending become excluding?',
  'The shift from omit reflects three major forces: lexical competition with "send," moralization of completeness, and the bureaucratic need for precision in record-keeping.',
  false,
  NOW()
) RETURNING id AS omit_id;

-- Get the inserted ID for omit
DO $$
DECLARE
  omit_id INTEGER;
  event1_id INTEGER;
  event2_id INTEGER;
  event3_id INTEGER;
  lexical_tag_id INTEGER;
  moral_tag_id INTEGER;
  bureau_tag_id INTEGER;
BEGIN
  -- Get the ID of the omit entry
  SELECT id INTO omit_id FROM vocab_entries WHERE word = 'omit';
  
  -- Get tag IDs
  SELECT id INTO lexical_tag_id FROM causal_tags WHERE tag_name = 'lexical_competition';
  SELECT id INTO moral_tag_id FROM causal_tags WHERE tag_name = 'moralization';
  SELECT id INTO bureau_tag_id FROM causal_tags WHERE tag_name = 'bureaucratic_expansion';

  -- Insert timeline events for "omit"
  INSERT INTO word_timeline_events (
    vocab_entry_id, century, year, sense_at_time, sibling_words,
    cultural_context, causal_tensions, language_transitions,
    event_text, sort_order
  ) VALUES (
    omit_id, 1, NULL,
    'to send away, let go, release',
    ARRAY['mittere (send)', 'emittere (send out)', 'admittere (allow in)'],
    'Classical Latin, physical world of objects and messengers',
    'The prefix ob- (toward, against) combined with mittere created a sense of sending something in a direction that removes it from attention.',
    'Latin: ob + mittere → omittere',
    'In Classical Latin, omittere meant "to let fall," "to send away," or "to cease doing." It was a physical verb. When you omittere something, you released it from your grasp or attention — but the emphasis was on the action of sending or letting go, not on what remained.',
    1
  ) RETURNING id INTO event1_id;

  INSERT INTO word_timeline_events (
    vocab_entry_id, century, year, sense_at_time, sibling_words,
    cultural_context, causal_tensions, language_transitions,
    event_text, sort_order
  ) VALUES (
    omit_id, 12, NULL,
    'to leave undone, neglect',
    ARRAY['neglect', 'pretermit', 'pass over'],
    'Medieval scholastic Latin, focus on duty and completeness',
    'As literacy became tied to clerical and bureaucratic work, omitting something was no longer neutral — it became a failure of duty.',
    'Latin → Old French omettre → Middle English omitten',
    'By the 12th century, in medieval legal and ecclesiastical Latin, omittere had shifted toward "to leave undone" or "to neglect." This was not just physical letting-go — it was moral. Omitting a prayer, a name from a record, or a step in a ritual was a failure. The word began to carry weight.',
    2
  ) RETURNING id INTO event2_id;

  INSERT INTO word_timeline_events (
    vocab_entry_id, century, year, sense_at_time, sibling_words,
    cultural_context, causal_tensions, language_transitions,
    event_text, sort_order
  ) VALUES (
    omit_id, 16, NULL,
    'to exclude from a text, record, or account',
    ARRAY['exclude', 'leave out', 'suppress'],
    'Early modern print culture and textual scholarship',
    'The printing press made textual precision visible and valuable. What you left out of a printed text was as important as what you included.',
    'Middle English → Early Modern English',
    'With the rise of printing in the 16th century, "omit" became a technical editorial term. Editors and translators spoke of "omitting" passages, glosses, or commentary. The word's center of gravity moved fully into the textual realm — from physical sending to textual absence.',
    3
  ) RETURNING id INTO event3_id;

  -- Tag the events
  INSERT INTO timeline_event_tags (event_id, tag_id) VALUES
    (event1_id, lexical_tag_id),
    (event2_id, moral_tag_id),
    (event3_id, bureau_tag_id);
END $$;


-- Sample Entry 2: "learn"
INSERT INTO vocab_entries (
  word, part_of_speech, modern_definition, usage_example,
  synonyms, french_equivalent, russian_equivalent,
  cefr_level, is_mastered, date_added
) VALUES (
  'learn',
  'verb',
  'to gain knowledge or skill through study, experience, or being taught',
  'She learned to speak French fluently.',
  ARRAY['study', 'master', 'acquire'],
  'apprendre',
  'учить',
  'A1',
  false,
  NOW()
);


-- Sample Entry 3: "explore"
INSERT INTO vocab_entries (
  word, part_of_speech, modern_definition, usage_example,
  synonyms, french_equivalent, russian_equivalent,
  cefr_level, is_mastered, date_added
) VALUES (
  'explore',
  'verb',
  'to travel through an unfamiliar area to learn about it',
  'They explored the ancient ruins.',
  ARRAY['investigate', 'examine', 'discover'],
  'explorer',
  'исследовать',
  'B1',
  false,
  NOW()
);


-- Sample Entry 4: "vocabulary"
INSERT INTO vocab_entries (
  word, part_of_speech, modern_definition, usage_example,
  synonyms, french_equivalent, russian_equivalent,
  cefr_level, is_mastered, date_added
) VALUES (
  'vocabulary',
  'noun',
  'the body of words used in a particular language or field',
  'She has an impressive vocabulary.',
  ARRAY['lexicon', 'terminology', 'wordstock'],
  'vocabulaire',
  'словарный запас',
  'B1',
  true,
  NOW() - INTERVAL '2 days'
);

-- Sample Entry 5: "atlas"
INSERT INTO vocab_entries (
  word, part_of_speech, modern_definition, usage_example,
  french_equivalent, russian_equivalent,
  cefr_level, is_mastered, date_added
) VALUES (
  'atlas',
  'noun',
  'a book of maps or charts',
  'He consulted the atlas to find the location.',
  'atlas',
  'атлас',
  'B2',
  false,
  NOW() - INTERVAL '1 day'
);

COMMIT;

