// server/scripts/ingest_vocab.js
import fs from 'fs'
import path from 'path'
import { pool } from '../src/db/index.js'

// Ensure a vocab entry exists for a word; if not, create a stub.
// Returns the vocab entry id.
async function ensureWordExists(word) {
  const { rows } = await pool.query(
    `INSERT INTO vocab_entries (word)
     VALUES ($1)
     ON CONFLICT (word) DO UPDATE SET word = EXCLUDED.word
     RETURNING id`,
    [word]
  )
  return rows[0].id
}

// Insert a relation between two vocab entries.
async function insertRelation(sourceId, targetWord, relationType, bidirectional = false) {
  const targetId = await ensureWordExists(targetWord)

  await pool.query(
    `INSERT INTO word_relations (source_id, target_id, relation_type)
     VALUES ($1,$2,$3)
     ON CONFLICT DO NOTHING`,
    [sourceId, targetId, relationType]
  )

  // Bidirectional for synonyms
  if (bidirectional && relationType === 'synonym') {
    await pool.query(
      `INSERT INTO word_relations (source_id, target_id, relation_type)
       VALUES ($1,$2,$3)
       ON CONFLICT DO NOTHING`,
      [targetId, sourceId, relationType]
    )
  }
}

// Insert a timeline event and causal tags
async function insertTimelineEvent(vocabId, event) {
  const { century, story_text, causal_tags = [] } = event

  const { rows: eventRows } = await pool.query(
    `INSERT INTO word_timeline_events (vocab_entry_id, century, story_text)
     VALUES ($1,$2,$3)
     RETURNING id`,
    [vocabId, century, story_text]
  )
  const eventId = eventRows[0].id

  for (const tag of causal_tags) {
    const { rows: tagRows } = await pool.query(
      `INSERT INTO causal_tags (tag_name)
       VALUES ($1)
       ON CONFLICT (tag_name) DO UPDATE SET tag_name = EXCLUDED.tag_name
       RETURNING id`,
      [tag]
    )
    const tagId = tagRows[0].id
    await pool.query(
      `INSERT INTO timeline_event_tags (event_id, tag_id)
       VALUES ($1,$2)
       ON CONFLICT DO NOTHING`,
      [eventId, tagId]
    )
  }
}

// Main insertion for a single vocab entry
async function insertEntry(entry) {
  const {
    word,
    part_of_speech,
    modern_definition,
    usage_example,
    french_equiv,
    russian_equiv,
    synonyms = [],
    antonyms = [],
    related = [],
    story = []
  } = entry

  // Insert vocab entry (idempotent on word)
  const { rows } = await pool.query(
    `INSERT INTO vocab_entries (word, part_of_speech, modern_definition, usage_example, french_equiv, russian_equiv)
     VALUES ($1,$2,$3,$4,$5,$6)
     ON CONFLICT (word) DO UPDATE
       SET part_of_speech = EXCLUDED.part_of_speech,
           modern_definition = EXCLUDED.modern_definition,
           usage_example = EXCLUDED.usage_example,
           french_equiv = EXCLUDED.french_equiv,
           russian_equiv = EXCLUDED.russian_equiv
     RETURNING id`,
    [word, part_of_speech, modern_definition, usage_example, french_equiv, russian_equiv]
  )
  const vocabId = rows[0].id

  // Synonyms / Antonyms / Related
  for (const syn of synonyms) {
    await insertRelation(vocabId, syn, 'synonym', true)
  }
  for (const ant of antonyms) {
    await insertRelation(vocabId, ant, 'antonym')
  }
  for (const rel of related) {
    await insertRelation(vocabId, rel, 'related')
  }

  // Timeline events
  for (const ev of story) {
    await insertTimelineEvent(vocabId, ev)
  }
}

// Run the script
async function run() {
  const file = process.argv[2]
  if (!file) {
    console.error('Usage: node ingest_vocab.js path/to/file.json')
    process.exit(1)
  }

  const data = JSON.parse(fs.readFileSync(path.resolve(file), 'utf8'))

  for (const entry of data) {
    await insertEntry(entry)
  }

  console.log(`Inserted or updated ${data.length} entries`)
  process.exit(0)
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
