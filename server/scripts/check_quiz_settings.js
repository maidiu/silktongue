import { pool } from '../src/db/index.js';

async function checkQuizSettings() {
  try {
    const result = await pool.query(`
      SELECT word_id, level, question_type, options->>'settings' as settings_json
      FROM quiz_materials
      WHERE level IN (5, 6)
      AND question_type = 'story'
      ORDER BY word_id, level
      LIMIT 5
    `);
    
    console.log('Sample quiz settings from database:\n');
    result.rows.forEach(row => {
      console.log(`Word ID ${row.word_id} (Level ${row.level}):`);
      console.log(row.settings_json);
      console.log('---\n');
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkQuizSettings();

