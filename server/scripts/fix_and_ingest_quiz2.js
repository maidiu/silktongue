// server/scripts/fix_and_ingest_quiz2.js
// Fixes sample_quiz2.json and ingests it into the actual database schema

import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';

// This script now looks up word IDs dynamically from the database
// Quiz JSONs should use word names, not word IDs

// Fix question types and data structures to match your schema
function fixQuizData(rawData) {
  return rawData.map(question => {
    const fixed = { ...question };
    
    // Fix question types to match your schema constraints
    switch (question.question_type) {
      case 'synonym':
        fixed.question_type = 'synonym';
        // Keep options structure as is for synonym questions
        break;
        
      case 'story':
        fixed.question_type = 'story';
        // Keep options as array for story questions
        break;
        
      default:
        // Keep as is for spelling, typing, definition
        break;
    }
    
    return fixed;
  });
}

// Validate quiz question structure
function validateQuestion(question, index) {
  const errors = [];
  
  if (!question.word && !question.word_id) {
    errors.push(`Question ${index}: missing word name or word_id`);
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
  
  // Valid types based on your schema constraint
  const validTypes = ['spelling', 'typing', 'definition', 'synonym', 'antonym', 'story'];
  if (question.question_type && !validTypes.includes(question.question_type)) {
    errors.push(`Question ${index}: invalid question_type '${question.question_type}'`);
  }
  
  return errors;
}

// Get word_id from word name (handles both string names and numeric IDs)
async function getWordIdFromName(wordOrId) {
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

// Insert a quiz question into quiz_materials table
async function insertQuizMaterial(question) {
  const {
    level,
    question_type,
    prompt,
    options,
    correct_answer,
    variant_data,
    reward_amount = 10
  } = question;
  
  // Get word_id from word name
  const wordId = await getWordIdFromName(question.word || question.word_id);
  
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
        correct_answer || null,
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
        correct_answer || null,
        variant_data ? JSON.stringify(variant_data) : null,
        reward_amount
      ]
    );
    return rows[0];
  }
}

// Main ingestion function
async function fixAndIngestQuiz2() {
  console.log(`\n📚 Fixing and ingesting sample_quiz2.json into quiz_materials table...\n`);
  
  const filePath = path.resolve('weekly_quizzes/sample_quiz2.json');
  const rawData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  
  console.log(`📝 Fixing quiz data...`);
  const fixedData = fixQuizData(rawData);
  
  console.log(`✅ Fixed ${fixedData.length} questions`);
  console.log(`📊 Word ID mapping applied:`);
  Object.entries(WORD_ID_MAPPING).forEach(([oldId, newId]) => {
    console.log(`   ${oldId} → ${newId}`);
  });
  
  let successCount = 0;
  let errorCount = 0;
  
  for (let i = 0; i < fixedData.length; i++) {
    const question = fixedData[i];
    
    // Validate
    const validationErrors = validateQuestion(question, i + 1);
    if (validationErrors.length > 0) {
      console.error(`❌ Validation failed for question ${i + 1}:`);
      validationErrors.forEach(err => console.error(`   - ${err}`));
      errorCount++;
      continue;
    }
    
    try {
      const result = await insertQuizMaterial(question);
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
  
  // Show summary by word
  console.log(`📋 Summary by word:`);
  const wordGroups = {};
  fixedData.forEach(q => {
    const wordName = q.word || q.word_id;
    if (!wordGroups[wordName]) wordGroups[wordName] = [];
    wordGroups[wordName].push(q);
  });
  
  for (const [wordName, questions] of Object.entries(wordGroups)) {
    console.log(`   Word "${wordName}": ${questions.length} questions`);
  }
  
  // Show what's now in the database
  console.log(`\n📊 Database contents:`);
  const { rows } = await pool.query(`
    SELECT word_id, level, question_type, COUNT(*) as count
    FROM quiz_materials 
    GROUP BY word_id, level, question_type
    ORDER BY word_id, level
  `);
  
  rows.forEach(row => {
    console.log(`   Word ${row.word_id}, Level ${row.level}: ${row.question_type}`);
  });
}

// Script execution
async function run() {
  try {
    await fixAndIngestQuiz2();
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Fatal error during ingestion:');
    console.error(err);
    process.exit(1);
  }
}

run();
