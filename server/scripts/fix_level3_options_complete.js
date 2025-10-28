import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function fixLevel3Options() {
  try {
    console.log('🔄 Fixing Level 3 quiz options from source files...\n');
    
    // Load the source quiz files
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const week1Quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    const week2Quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    const allQuizzes = [...week1Quizzes, ...week2Quizzes];
    
    // Filter for level 3 definition quizzes
    const level3Quizzes = allQuizzes.filter(q => 
      q.level === 3 && q.question_type === 'definition'
    );
    
    console.log(`Found ${level3Quizzes.length} Level 3 definition quizzes in source files\n`);
    
    let fixed = 0;
    let skipped = 0;
    
    for (const quiz of level3Quizzes) {
      const { word_id, incorrect_answers, correct_answers } = quiz;
      
      if (!incorrect_answers || !correct_answers) {
        console.log(`  ⚠️  Quiz for word_id ${word_id} missing answer arrays, skipping`);
        skipped++;
        continue;
      }
      
      // Create proper options structure
      const options = {
        incorrect_answers,
        correct_answers
      };
      
      // Update in database
      const result = await pool.query(`
        UPDATE quiz_materials 
        SET options = $1
        WHERE word_id = $2 AND level = 3 AND question_type = 'definition'
        RETURNING id
      `, [JSON.stringify(options), word_id]);
      
      if (result.rowCount > 0) {
        console.log(`  ✓ Fixed quiz for word_id ${word_id} (${incorrect_answers.length} incorrect, ${correct_answers.length} correct)`);
        fixed++;
      } else {
        console.log(`  ⚠️  No quiz found in database for word_id ${word_id}`);
        skipped++;
      }
    }
    
    console.log(`\n✅ Complete! Fixed ${fixed} quizzes, skipped ${skipped}`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

fixLevel3Options();

