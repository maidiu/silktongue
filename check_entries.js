import { pool } from './server/src/db/index.js';

async function checkEntries() {
  try {
    const result = await pool.query(
      `SELECT id, word, date_added FROM vocab_entries ORDER BY date_added DESC LIMIT 20`
    );
    console.log('Latest 20 entries:');
    result.rows.forEach(row => {
      console.log(`${row.id}: ${row.word} (${row.date_added})`);
    });
    await pool.end();
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkEntries();
