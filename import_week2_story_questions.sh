#!/bin/bash
# Quick script to import week 2 story comprehension questions
cd /var/www/maxvocab/server

node << 'JS'
import fs from 'fs';
import { pool } from './src/db/index.js';

const data = JSON.parse(fs.readFileSync('../story_comprehension_questions_2025.10.25.json', 'utf8'));

console.log(`Found ${data.length} words with questions\n`);

let totalQuestions = 0;

for (const wordData of data) {
  // Look up actual word_id
  const wordLookup = await pool.query(
    'SELECT id FROM vocab_entries WHERE word = $1',
    [wordData.word]
  );
  
  if (wordLookup.rows.length === 0) {
    console.log(`⚠ Skipping ${wordData.word}: not found in database`);
    continue;
  }
  
  const actualWordId = wordLookup.rows[0].id;
  console.log(`Processing: ${wordData.word} (ID: ${actualWordId})`);
  
  for (const q of wordData.questions) {
    await pool.query(
      `INSERT INTO story_comprehension_questions 
       (word_id, century, question, options, correct_answer, explanation) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [actualWordId, q.century, q.question, JSON.stringify(q.options), q.correct_answer, q.explanation]
    );
    totalQuestions++;
  }
}

console.log(`\n✅ Imported ${totalQuestions} questions`);
await pool.end();
JS

echo "Done!"

