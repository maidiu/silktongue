import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';

// This script ingests quiz data from sample_quiz3.json
// which follows the correct structure from sample_quiz.json

// Cache for word IDs
const wordIdCache = new Map();

async function getWordIdFromName(wordName) {
  if (wordIdCache.has(wordName)) {
    return wordIdCache.get(wordName);
  }

  const { rows } = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [wordName]);
  if (rows.length > 0) {
    wordIdCache.set(wordName, rows[0].id);
    return rows[0].id;
  }
  return null;
}

// Validate quiz question structure
function validateQuestion(question, index) {
  const errors = [];
  
  if (!question.word) {
    errors.push(`Question ${index}: missing word name`);
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
  
  // Valid types based on the schema constraint
  const validTypes = ['spelling', 'typing', 'definition', 'synonym', 'antonym', 'story'];
  if (question.question_type && !validTypes.includes(question.question_type)) {
    errors.push(`Question ${index}: invalid question_type '${question.question_type}'`);
  }
  
  return errors;
}

// Insert a quiz question into quiz_materials table
async function insertQuizMaterial(question) {
  const {
    level,
    question_type,
    prompt,
    options,
    correct_answer,
    variant_data,
    reward_amount = 10,
    difficulty = 'normal'
  } = question;
  
  // Get word_id from word name
  const wordId = await getWordIdFromName(question.word);
  if (!wordId) {
    throw new Error(`Word '${question.word}' not found in vocab_entries.`);
  }
  
  // First check if it already exists
  const existing = await pool.query(
    'SELECT id FROM quiz_materials WHERE word_id = $1 AND level = $2',
    [wordId, level]
  );
  
  if (existing.rows.length > 0) {
    // Update existing
    const { rows } = await pool.query(
      `UPDATE quiz_materials SET
        question_type = $3,
        prompt = $4,
        options = $5,
        correct_answer = $6,
        variant_data = $7,
        reward_amount = $8,
        updated_at = NOW()
      WHERE word_id = $1 AND level = $2
      RETURNING id, word_id, level`,
      [
        wordId,
        level,
        question_type,
        prompt,
        options ? JSON.stringify(options) : null,
        correct_answer ? (Array.isArray(correct_answer) ? JSON.stringify(correct_answer) : correct_answer) : null,
        variant_data ? JSON.stringify(variant_data) : null,
        reward_amount
      ]
    );
    return rows[0];
  } else {
    // Insert new
    const { rows } = await pool.query(
      `INSERT INTO quiz_materials (
        word_id, level, question_type, prompt,
        options, correct_answer, variant_data, reward_amount
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, word_id, level`,
      [
        wordId,
        level,
        question_type,
        prompt,
        options ? JSON.stringify(options) : null,
        correct_answer ? (Array.isArray(correct_answer) ? JSON.stringify(correct_answer) : correct_answer) : null,
        variant_data ? JSON.stringify(variant_data) : null,
        reward_amount
      ]
    );
    return rows[0];
  }
}

// Main ingestion function
async function ingestQuiz3() {
  console.log(`\n📚 Ingesting sample_quiz3.json into quiz_materials table...\n`);
  
  const filePath = path.resolve(process.cwd(), 'weekly_quizzes/sample_quiz3.json');
  let rawData;
  try {
    rawData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (err) {
    console.error(`❌ Error reading or parsing ${filePath}:`, err.message);
    return;
  }

  console.log(`📝 Found ${rawData.length} questions`);

  const wordIdMap = new Map();
  const wordCounts = new Map();
  let successCount = 0;
  let errorCount = 0;

  // Pre-populate word ID cache
  const { rows: vocabEntries } = await pool.query('SELECT id, word FROM vocab_entries');
  vocabEntries.forEach(entry => wordIdCache.set(entry.word, entry.id));

  for (let i = 0; i < rawData.length; i++) {
    const question = rawData[i];
    const errors = validateQuestion(question, i);
    if (errors.length > 0) {
      console.error(`  ❌ Validation errors for question ${i + 1}:`, errors.join(', '));
      errorCount++;
      continue;
    }
    
    try {
      const result = await insertQuizMaterial(question);
      console.log(`  ✓ Question ${i + 1}: word_id=${result.word_id}, level=${result.level}, type=${question.question_type}`);
      successCount++;

      const wordName = question.word;
      wordIdMap.set(wordName, result.word_id);
      wordCounts.set(wordName, (wordCounts.get(wordName) || 0) + 1);

    } catch (err) {
      console.error(`  ❌ Failed to insert question ${i + 1}:`, err.message);
      errorCount++;
    }
  }

  console.log(`\n✅ Ingestion complete: ${successCount} succeeded, ${errorCount} failed\n`);

  if (wordIdMap.size > 0) {
    console.log('📋 Summary by word:');
    wordIdMap.forEach((id, word) => {
      console.log(`   Word ID ${id} (${word}): ${wordCounts.get(word)} questions`);
    });
  }

  // Verify database contents
  console.log('\n📊 Database contents:');
  const { rows: dbContents } = await pool.query(
    `SELECT ve.word, qm.level, qm.question_type
     FROM quiz_materials qm
     JOIN vocab_entries ve ON qm.word_id = ve.id
     WHERE ve.word = 'perfunctory'
     ORDER BY qm.level`
  );
  dbContents.forEach(row => {
    console.log(`   Word ${row.word}, Level ${row.level}: ${row.question_type}`);
  });
}

// Script execution
async function run() {
  try {
    await ingestQuiz3();
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Fatal error during ingestion:');
    console.error(err);
    process.exit(1);
  }
}

run();

