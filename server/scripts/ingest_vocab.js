// server/scripts/ingest_vocab_enhanced.js
// Enhanced ingestion script that handles the full schema capabilities

import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';

// =========================================================================
// Helper Functions
// =========================================================================

// Ensure a vocab entry exists for a word; if not, create a stub.
// Returns the vocab entry id.
async function ensureWordExists(word) {
  const { rows } = await pool.query(
    `INSERT INTO vocab_entries (word)
     VALUES ($1)
     ON CONFLICT (word) DO UPDATE SET word = EXCLUDED.word
     RETURNING id`,
    [word]
  );
  return rows[0].id;
}

// Insert or update a complete vocab entry (enhanced)
async function upsertVocabEntry(entry) {
  const {
    word,
    part_of_speech,
    modern_definition,
    usage_example,
    synonyms = [],
    antonyms = [],
    collocations,
    cefr_level,
    pronunciation,
    story_text,
    contrastive_opening,
    structural_analysis,
    common_collocations = [],
    metadata = {},

    // new fields
    definitions = {},
    variant_forms = [],
    semantic_field = [],
    english_synonyms = [],
    english_antonyms = [],
    french_synonyms = [],
    french_root_cognates = [],
    russian_synonyms = [],
    russian_root_cognates = [],
    common_phrases = [],
    story_intro = null,
    story = []
  } = entry;

  // Accept both JSON spellings and map to DB columns
  const french_equivalent = entry.french_equivalent ?? entry.french_equiv ?? null;
  const russian_equivalent = entry.russian_equivalent ?? entry.russian_equiv ?? null;

  const { rows } = await pool.query(
    `INSERT INTO vocab_entries (
        word, part_of_speech, modern_definition, usage_example,
        synonyms, antonyms, collocations,
        french_equivalent, russian_equivalent, cefr_level, pronunciation,
        story_text, contrastive_opening, structural_analysis,
        common_collocations, metadata,
        definitions, variant_forms, semantic_field,
        english_synonyms, english_antonyms,
        french_synonyms, french_root_cognates,
        russian_synonyms, russian_root_cognates,
        common_phrases, story_intro
    )
    VALUES (
        $1, $2, $3, $4,
        $5, $6, $7,
        $8, $9, $10, $11,
        $12, $13, $14,
        $15, $16,
        $17, $18, $19,
        $20, $21,
        $22, $23,
        $24, $25,
        $26, $27
    )
    ON CONFLICT (word) DO UPDATE SET
        part_of_speech = EXCLUDED.part_of_speech,
        modern_definition = EXCLUDED.modern_definition,
        usage_example = EXCLUDED.usage_example,
        synonyms = EXCLUDED.synonyms,
        antonyms = EXCLUDED.antonyms,
        collocations = EXCLUDED.collocations,
        french_equivalent = EXCLUDED.french_equivalent,
        russian_equivalent = EXCLUDED.russian_equivalent,
        cefr_level = EXCLUDED.cefr_level,
        pronunciation = EXCLUDED.pronunciation,
        story_text = EXCLUDED.story_text,
        contrastive_opening = EXCLUDED.contrastive_opening,
        structural_analysis = EXCLUDED.structural_analysis,
        common_collocations = EXCLUDED.common_collocations,
        metadata = EXCLUDED.metadata,
        definitions = EXCLUDED.definitions,
        variant_forms = EXCLUDED.variant_forms,
        semantic_field = EXCLUDED.semantic_field,
        english_synonyms = EXCLUDED.english_synonyms,
        english_antonyms = EXCLUDED.english_antonyms,
        french_synonyms = EXCLUDED.french_synonyms,
        french_root_cognates = EXCLUDED.french_root_cognates,
        russian_synonyms = EXCLUDED.russian_synonyms,
        russian_root_cognates = EXCLUDED.russian_root_cognates,
        common_phrases = EXCLUDED.common_phrases,
        story_intro = EXCLUDED.story_intro
    RETURNING id`,
    [
      word, part_of_speech, modern_definition, usage_example,
      synonyms, antonyms, collocations ? JSON.stringify(collocations) : '{}',
      french_equivalent, russian_equivalent, cefr_level, pronunciation,
      story_text, contrastive_opening, structural_analysis,
      common_collocations, metadata ? JSON.stringify(metadata) : '{}',
      JSON.stringify(definitions), variant_forms, semantic_field,
      english_synonyms, english_antonyms,
      french_synonyms, french_root_cognates,
      russian_synonyms, russian_root_cognates,
      common_phrases,
      entry.story_intro ?? null
    ]
  );

  return rows[0].id;
}

// Insert a relation between two vocab entries
async function insertRelation(sourceId, targetWord, relationType, bidirectional = false) {
  const targetId = await ensureWordExists(targetWord);

  await pool.query(
    `INSERT INTO word_relations (source_id, target_id, relation_type)
     VALUES ($1, $2, $3)
     ON CONFLICT (source_id, target_id, relation_type) DO NOTHING`,
    [sourceId, targetId, relationType]
  );

  // Bidirectional for synonyms
  if (bidirectional && relationType === 'synonym') {
    await pool.query(
      `INSERT INTO word_relations (source_id, target_id, relation_type)
       VALUES ($1, $2, $3)
       ON CONFLICT (source_id, target_id, relation_type) DO NOTHING`,
      [targetId, sourceId, relationType]
    );
  }
}

// Insert a timeline event with all metadata
async function insertTimelineEvent(vocabId, event) {
  const {
    century,
    event_text,
    sibling_words = [],
    context,
    causal_tags = [],
    citations = []
  } = {
    // Support @2025.10.17.json shape where the key is story_text
    event_text: event.event_text ?? event.story_text,
    ...event
  };

  // Insert the timeline event
  const { rows: eventRows } = await pool.query(
    `INSERT INTO word_timeline_events (
      vocab_id, century, event_text, sibling_words, context
    )
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id`,
    [
      vocabId, century, event_text, sibling_words, context
    ]
  );
  const eventId = eventRows[0].id;

  // Link causal tags
  for (const tagName of causal_tags) {
    // Ensure tag exists
    const { rows: tagRows } = await pool.query(
      `INSERT INTO causal_tags (tag_name)
       VALUES ($1)
       ON CONFLICT (tag_name) DO UPDATE SET tag_name = EXCLUDED.tag_name
       RETURNING id`,
      [tagName]
    );
    const tagId = tagRows[0].id;
    
    // Link tag to event
    await pool.query(
      `INSERT INTO timeline_event_tags (event_id, tag_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [eventId, tagId]
    );
  }

  // Note: Citations not supported in current schema

  return eventId;
}

// Insert root family links
async function insertRootLinks(vocabId, roots = []) {
  for (const rootInfo of roots) {
    const { root_word, language, gloss, relation_description } = rootInfo;
    
    // Ensure root family exists
    const { rows: rootRows } = await pool.query(
      `INSERT INTO root_families (root_word, language, gloss)
       VALUES ($1, $2, $3)
       ON CONFLICT (root_word, language) DO UPDATE 
       SET gloss = EXCLUDED.gloss
       RETURNING id`,
      [root_word, language, gloss]
    );
    const rootId = rootRows[0].id;
    
    // Link vocab entry to root
    await pool.query(
      `INSERT INTO word_root_links (vocab_id, root_id, relation_description)
       VALUES ($1, $2, $3)
       ON CONFLICT (vocab_id, root_id) DO UPDATE
       SET relation_description = EXCLUDED.relation_description`,
      [vocabId, rootId, relation_description]
    );
  }
}

// Insert semantic domain links
async function insertDomainLinks(vocabId, domains = []) {
  for (const domainName of domains) {
    // Ensure domain exists
    const { rows: domainRows } = await pool.query(
      `INSERT INTO semantic_domains (name)
       VALUES ($1)
       ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
       RETURNING id`,
      [domainName]
    );
    const domainId = domainRows[0].id;
    
    // Link vocab entry to domain
    await pool.query(
      `INSERT INTO vocab_domain_links (vocab_id, domain_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [vocabId, domainId]
    );
  }
}

// Insert derivational relations
async function insertDerivations(vocabId, derivations = []) {
  for (const deriv of derivations) {
    const { related_word, relation_type, notes, direction } = deriv;
    const relatedId = await ensureWordExists(related_word);
    
    // Determine parent/child based on direction
    const [parentId, childId] = direction === 'parent' 
      ? [relatedId, vocabId]  // related_word is the parent
      : [vocabId, relatedId]; // current word is the parent
    
    await pool.query(
      `INSERT INTO derivations (parent_vocab_id, child_vocab_id, relation_type, notes)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (parent_vocab_id, child_vocab_id, relation_type) DO UPDATE
       SET notes = EXCLUDED.notes`,
      [parentId, childId, relation_type, notes]
    );
  }
}

// =========================================================================
// Main Entry Insertion Function
// =========================================================================

async function insertEntry(entry) {
  const {
    word,
    synonyms = [],
    antonyms = [],
    related = [],
    timeline = [],
    story = [], // support old key name
    roots = [],
    domains = [],
    derivations = []
  } = entry;

  console.log(`  Processing: ${word}`);

  // 1. Insert/update the main vocab entry
  const vocabId = await upsertVocabEntry(entry);

  // 2. Insert word relations (synonyms, antonyms, related)
  for (const syn of synonyms) {
    await insertRelation(vocabId, syn, 'synonym', true);
  }
  for (const ant of antonyms) {
    await insertRelation(vocabId, ant, 'antonym');
  }
  for (const rel of related) {
    await insertRelation(vocabId, rel, 'related');
  }

  // 3. Insert timeline events (with tags and citations)
  // First, delete existing timeline events to prevent duplicates
  await pool.query('DELETE FROM word_timeline_events WHERE vocab_id = $1', [vocabId]);
  
  const events = (timeline && timeline.length ? timeline : story);
  for (const event of events) {
    await insertTimelineEvent(vocabId, event);
  }

  // 4. Insert root family links
  await insertRootLinks(vocabId, roots);

  // 5. Insert semantic domain links
  await insertDomainLinks(vocabId, domains);

  // 6. Insert derivational relations
  await insertDerivations(vocabId, derivations);

  console.log(`    ✓ Inserted/updated ${word} with ${events.length} timeline events`);
}

// =========================================================================
// Script Execution
// =========================================================================

async function run() {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: node ingest_vocab.js path/to/file.json');
    process.exit(1);
  }

  try {
    const data = JSON.parse(fs.readFileSync(path.resolve(file), 'utf8'));
    const entries = Array.isArray(data) ? data : [data];

    console.log(`\n📚 Ingesting ${entries.length} vocabulary ${entries.length === 1 ? 'entry' : 'entries'}...\n`);

    for (const entry of entries) {
      await insertEntry(entry);
    }

    console.log(`\n✅ Successfully ingested ${entries.length} ${entries.length === 1 ? 'entry' : 'entries'}\n`);
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Error during ingestion:');
    console.error(err);
    process.exit(1);
  }
}

run();

