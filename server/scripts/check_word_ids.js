import { pool } from '../src/db/index.js';

async function checkWordIds() {
  try {
    console.log('Checking word IDs for story comprehension questions...');
    
    const { rows } = await pool.query(`
      SELECT word_id, COUNT(*) as question_count
      FROM story_comprehension_questions
      GROUP BY word_id
      ORDER BY word_id
    `);
    
    console.log('Story comprehension questions by word_id:');
    rows.forEach(row => {
      console.log(`  Word ID ${row.word_id}: ${row.question_count} questions`);
    });
    
    console.log('\nChecking vocabulary entries:');
    const { rows: vocabRows } = await pool.query(`
      SELECT id, word FROM vocab_entries ORDER BY id
    `);
    
    vocabRows.forEach(row => {
      console.log(`  ID ${row.id}: ${row.word}`);
    });
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

checkWordIds();

