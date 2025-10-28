import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function reimportWeek2Level3() {
  try {
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    console.log('🔄 Re-importing Week 2 Level 3 quizzes...\n');
    
    let updated = 0;
    
    for (const quiz of quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition' && quiz.word_id) {
        console.log(`  ✓ Updating ${quiz.word || 'word_id ' + quiz.word_id}`);
        
        // Update the quiz_materials table
        await pool.query(`
          UPDATE quiz_materials 
          SET options = $1
          WHERE word_id = $2 AND level = 3 AND question_type = 'definition'
        `, [JSON.stringify(quiz.options), quiz.word_id]);
        
        updated++;
      }
    }
    
    console.log(`\n✅ Updated ${updated} Level 3 quizzes in database`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

reimportWeek2Level3();

