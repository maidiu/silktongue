// server/scripts/ingest_quizzes.js
// Ingests quiz questions from JSON files into the database

import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';

// Validate quiz question structure
function validateQuestion(question, index) {
  const errors = [];
  
  if (!question.word_id && !question.word) {
    errors.push(`Question ${index}: missing word_id or word`);
  }
  if (!question.level) {
    errors.push(`Question ${index}: missing level`);
  }
  if (!question.question_type) {
    errors.push(`Question ${index}: missing question_type`);
  }
  if (!question.prompt) {
    errors.push(`Question ${index}: missing prompt`);
  }
  
  const validTypes = ['spelling', 'typing', 'definition', 'synonym', 'antonym', 'story', 'story_reorder', 'syn_ant_sort'];
  if (question.question_type && !validTypes.includes(question.question_type)) {
    errors.push(`Question ${index}: invalid question_type '${question.question_type}'`);
  }
  
  return errors;
}

// Get or find word_id
async function getWordId(wordOrId) {
  if (typeof wordOrId === 'number') {
    return wordOrId;
  }
  
  // Look up by word text
  const { rows } = await pool.query(
    'SELECT id FROM vocab_entries WHERE word = $1',
    [wordOrId]
  );
  
  if (rows.length === 0) {
    throw new Error(`Word '${wordOrId}' not found in vocab_entries`);
  }
  
  return rows[0].id;
}

// Upsert a quiz question
async function upsertQuizQuestion(question) {
  const {
    level,
    question_type,
    prompt,
    options,
    correct_answer,
    variant_data,
    reward_amount = 10
  } = question;
  
  // Get word_id
  const word_id = await getWordId(question.word_id || question.word);
  
  const { rows } = await pool.query(
    `INSERT INTO quiz_materials (
      word_id, level, question_type, prompt,
      options, correct_answer,
      variant_data, reward_amount
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    ON CONFLICT (word_id, level) DO UPDATE SET
      question_type = EXCLUDED.question_type,
      prompt = EXCLUDED.prompt,
      options = EXCLUDED.options,
      correct_answer = EXCLUDED.correct_answer,
      variant_data = EXCLUDED.variant_data,
      reward_amount = EXCLUDED.reward_amount
    RETURNING id, word_id, level`,
    [
      word_id,
      level,
      question_type,
      prompt,
      options ? JSON.stringify(options) : null,
      correct_answer || null,
      variant_data ? JSON.stringify(variant_data) : null,
      reward_amount
    ]
  );
  
  return rows[0];
}

// Main ingestion function
async function ingestQuizFile(filePath) {
  console.log(`\n📚 Ingesting quiz file: ${filePath}\n`);
  
  const data = JSON.parse(fs.readFileSync(path.resolve(filePath), 'utf8'));
  const questions = Array.isArray(data) ? data : [data];
  
  let successCount = 0;
  let errorCount = 0;
  
  for (let i = 0; i < questions.length; i++) {
    const question = questions[i];
    
    // Validate
    const validationErrors = validateQuestion(question, i + 1);
    if (validationErrors.length > 0) {
      console.error(`❌ Validation failed for question ${i + 1}:`);
      validationErrors.forEach(err => console.error(`   - ${err}`));
      errorCount++;
      continue;
    }
    
    try {
      const result = await upsertQuizQuestion(question);
      console.log(`  ✓ Question ${i + 1}: word_id=${result.word_id}, level=${result.level}, type=${question.question_type}`);
      successCount++;
    } catch (err) {
      console.error(`  ❌ Failed to insert question ${i + 1}:`, err.message);
      errorCount++;
    }
  }
  
  console.log(`\n✅ Ingestion complete: ${successCount} succeeded, ${errorCount} failed\n`);
  
  if (errorCount > 0) {
    process.exit(1);
  }
}

// Script execution
async function run() {
  const file = process.argv[2];
  
  if (!file) {
    console.error('Usage: node ingest_quizzes.js path/to/quiz.json');
    process.exit(1);
  }
  
  try {
    await ingestQuizFile(file);
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Fatal error during ingestion:');
    console.error(err);
    process.exit(1);
  }
}

run();

