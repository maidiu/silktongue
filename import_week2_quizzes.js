import fs from 'fs';
import { pool } from './server/src/db/index.js';

const levels = JSON.parse(fs.readFileSync('weekly_quizzes/levels_1-5_2025.10.25.json'));
const level6 = JSON.parse(fs.readFileSync('weekly_quizzes/level6_quizzes_2025.10.25.json'));

async function insert(q) {
  const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [q.word]);
  if (wordRes.rows.length === 0) {
    console.log('Skipping:', q.word);
    return;
  }
  const word_id = wordRes.rows[0].id;
  
  try {
    await pool.query(
      `INSERT INTO quiz_materials (word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        word_id, 
        q.level, 
        q.question_type, 
        q.prompt, 
        q.options ? JSON.stringify(q.options) : null, 
        q.correct_answer, 
        q.variant_data ? JSON.stringify(q.variant_data) : null, 
        q.reward_amount || 10
      ]
    );
    console.log('✓', q.word, 'level', q.level);
  } catch (e) {
    console.log('✗', q.word, 'level', q.level, e.message);
  }
}

async function main() {
  for (const q of [...levels, ...level6]) {
    await insert(q);
  }
  await pool.end();
}

main();
