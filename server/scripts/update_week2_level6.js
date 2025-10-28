import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function updateWeek2Level6() {
  try {
    const filePath = path.join(__dirname, '../../weekly_quizzes/level6_quizzes_2025.10.25.json');
    const quizzes = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    
    console.log(`Updating Level 6 quizzes for ${quizzes.length} week 2 words...\n`);
    
    for (const quiz of quizzes) {
      // Look up word_id
      const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [quiz.word]);
      if (wordRes.rows.length === 0) {
        console.log(`⚠️  ${quiz.word} not found`);
        continue;
      }
      
      const word_id = wordRes.rows[0].id;
      
      // Delete existing Level 6 quiz
      await pool.query('DELETE FROM quiz_materials WHERE word_id = $1 AND level = 6', [word_id]);
      
      // Insert new quiz
      await pool.query(
        'INSERT INTO quiz_materials (word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
        [
          word_id,
          quiz.level,
          quiz.question_type,
          quiz.prompt,
          JSON.stringify(quiz.options),
          typeof quiz.correct_answer === 'string' ? quiz.correct_answer : JSON.stringify(quiz.correct_answer),
          quiz.variant_data ? JSON.stringify(quiz.variant_data) : null,
          quiz.reward_amount || 50
        ]
      );
      
      console.log(`✓ Updated ${quiz.word} Level 6`);
    }
    
    console.log(`\n✅ All Week 2 Level 6 quizzes updated!`);
    
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await pool.end();
  }
}

updateWeek2Level6();

