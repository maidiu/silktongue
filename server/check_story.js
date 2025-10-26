import { pool } from './src/db/index.js';

async function checkStory() {
  try {
    const result = await pool.query(
      'SELECT vocab_id, COUNT(*) as count FROM word_timeline_events GROUP BY vocab_id'
    );
    console.log('Timeline events by word:');
    result.rows.forEach(row => {
      console.log(`  Word ID ${row.vocab_id}: ${row.count} events`);
    });
    
    const entryResult = await pool.query('SELECT id, word, story_intro FROM vocab_entries WHERE id = 1');
    console.log('\nImpede entry:', entryResult.rows[0]);
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkStory();
