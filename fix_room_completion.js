import { pool } from './server/src/db/index.js';

async function fixRoomCompletion() {
  try {
    await pool.query(
      `UPDATE user_room_unlocks 
       SET completed_at = NOW() 
       WHERE room_id IN (121, 123) AND user_id = 5`
    );
    console.log('✅ Updated room completion status for impede and cohesive');
    await pool.end();
  } catch (error) {
    console.error('Error:', error.message);
  }
}

fixRoomCompletion();
