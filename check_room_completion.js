import { pool } from './server/src/db/index.js';

async function checkRoomCompletion() {
  try {
    // Get word IDs for impede and cohesive
    const wordResult = await pool.query(
      `SELECT id, word FROM vocab_entries WHERE word IN ('impede', 'cohesive')`
    );
    
    console.log('Words:', wordResult.rows);
    
    // For each word, check room unlock status
    for (const word of wordResult.rows) {
      const roomResult = await pool.query(
        `SELECT r.id, r.word_id, r.name, 
                uru.id as unlock_id, uru.completed_at
         FROM rooms r
         LEFT JOIN user_room_unlocks uru ON r.id = uru.room_id AND uru.user_id = 5
         WHERE r.word_id = $1`,
        [word.id]
      );
      
      console.log(`\n${word.word} (id: ${word.id}):`);
      console.log(roomResult.rows);
    }
    
    await pool.end();
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkRoomCompletion();
