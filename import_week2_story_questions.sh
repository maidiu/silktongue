#!/bin/bash
# Quick script to import week 2 story comprehension questions
cd /Users/matthewsmith/Desktop/MaxVocab

node << 'JS'
import fs from 'fs';
import { pool } from './server/src/db/index.js';

const data = JSON.parse(fs.readFileSync('story_comprehension_questions_2025.10.25.json', 'utf8'));

console.log(`Found ${data.length} items to process\n`);

let totalQuestions = 0;

for (const item of data) {
  // Skip if no word field
  if (!item.word) continue;
  
  // Look up actual word_id
  const wordLookup = await pool.query(
    'SELECT id FROM vocab_entries WHERE word = $1',
    [item.word]
  );
  
  if (wordLookup.rows.length === 0) {
    console.log(`⚠ Skipping ${item.word}: not found in database`);
    continue;
  }
  
  const actualWordId = wordLookup.rows[0].id;
  
  // Handle nested structure (with "questions" array)
  if (item.questions && Array.isArray(item.questions)) {
    console.log(`\nProcessing: ${item.word} (ID: ${actualWordId})`);
    
    for (const q of item.questions) {
      if (!q.question || !q.century) continue;
      
      await pool.query(
        `INSERT INTO story_comprehension_questions 
         (word_id, century, question, options, correct_answer, explanation) 
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (word_id, century) DO UPDATE SET
           question = EXCLUDED.question,
           options = EXCLUDED.options,
           correct_answer = EXCLUDED.correct_answer,
           explanation = EXCLUDED.explanation`,
        [actualWordId, q.century, q.question, JSON.stringify(q.options), q.correct_answer, q.explanation]
      );
      totalQuestions++;
    }
  } 
  // Handle flat structure (individual question objects)
  else if (item.question) {
    console.log(`Processing question: ${item.word}`);
    
    const century = item.story_part ? String(item.story_part - 1) : '1';
    
    await pool.query(
      `INSERT INTO story_comprehension_questions 
       (word_id, century, question, options, correct_answer, explanation) 
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (word_id, century) DO UPDATE SET
         question = EXCLUDED.question,
         options = EXCLUDED.options,
         correct_answer = EXCLUDED.correct_answer,
         explanation = EXCLUDED.explanation`,
      [actualWordId, century, item.question, JSON.stringify(item.options), item.correct_answer, item.explanation]
    );
    totalQuestions++;
  }
}

console.log(`\n✅ Imported ${totalQuestions} questions`);
await pool.end();
JS

echo "Done!"