import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function reimportAllLevel3() {
  try {
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const week1Quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    const week2Quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    const allQuizzes = [...week1Quizzes, ...week2Quizzes];
    
    console.log('🔄 Re-importing all Level 3 quizzes with standardized structure...\n');
    
    let updated = 0;
    
    for (const quiz of allQuizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        // Get the word_id from the database
        const wordResult = await pool.query(
          'SELECT id FROM vocab_entries WHERE word = $1',
          [quiz.word]
        );
        
        if (wordResult.rows.length === 0) {
          console.log(`  ⚠️  Word not found: ${quiz.word}`);
          continue;
        }
        
        const word_id = wordResult.rows[0].id;
        
        console.log(`  ✓ Updating ${quiz.word}`);
        
        // Store the data with top-level incorrect_answers and correct_answers
        const optionsData = {
          incorrect_answers: quiz.incorrect_answers,
          correct_answers: quiz.correct_answers
        };
        
        // Update the quiz_materials table
        await pool.query(`
          UPDATE quiz_materials 
          SET options = $1,
              prompt = $2,
              variant_data = $3
          WHERE word_id = $4 AND level = 3 AND question_type = 'definition'
        `, [
          JSON.stringify(optionsData),
          quiz.prompt,
          quiz.variant_data ? JSON.stringify(quiz.variant_data) : null,
          word_id
        ]);
        
        updated++;
      }
    }
    
    console.log(`\n✅ Re-imported ${updated} Level 3 quizzes`);
    await pool.end();
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

reimportAllLevel3();

