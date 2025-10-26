#!/bin/bash
# Quick script to import week 2 story comprehension questions
cd /var/www/maxvocab/server

node << 'JS'
import fs from 'fs';
import { pool } from './src/db/index.js';

const data = JSON.parse(fs.readFileSync('../story_comprehension_questions_2025.10.25.json', 'utf8'));

console.log(`Found ${data.length} questions to import\n`);

let totalQuestions = 0;
let lastWord = '';

for (const q of data) {
  // Look up actual word_id
  const wordLookup = await pool.query(
    'SELECT id FROM vocab_entries WHERE word = $1',
    [q.word]
  );
  
  if (wordLookup.rows.length === 0) {
    console.log(`⚠ Skipping ${q.word}: not found in database`);
    continue;
  }
  
  const actualWordId = wordLookup.rows[0].id;
  
  // Log when we move to a new word
  if (q.word !== lastWord) {
    console.log(`\nProcessing: ${q.word} (ID: ${actualWordId})`);
    lastWord = q.word;
  }
  
  // Extract century from story_part or use a default
  const century = q.story_part ? String(q.story_part - 1) : '1'; // story_part 1=century 0, etc.
  
  await pool.query(
    `INSERT INTO story_comprehension_questions 
     (word_id, century, question, options, correct_answer, explanation) 
     VALUES ($1, $2, $3, $4, $5, $6)
     ON CONFLICT (word_id, century) DO UPDATE SET
       question = EXCLUDED.question,
       options = EXCLUDED.options,
       correct_answer = EXCLUDED.correct_answer,
       explanation = EXCLUDED.explanation`,
    [actualWordId, century, q.question, JSON.stringify(q.options), q.correct_answer, q.explanation]
  );
  totalQuestions++;
  process.stdout.write('.');
}

console.log(`\n\n✅ Imported ${totalQuestions} questions`);
await pool.end();
JS

echo "Done!"

