import { pool } from '../src/db/index.js';

async function unlockGuardianForMatthew() {
  const client = await pool.connect();
  
  try {
    console.log('🔓 Unlocking guardian for Matthew...');
    
    // Find user "Matthew"
    const userRes = await client.query('SELECT id, username FROM users WHERE username = $1', ['Matthew']);
    if (userRes.rows.length === 0) {
      console.error('❌ User "Matthew" not found.');
      return;
    }
    const userId = userRes.rows[0].id;
    console.log(`✓ Found user: ${userRes.rows[0].username} (ID: ${userId})`);
    
    // Find the guardian room (boss_room with floor 1)
    const roomRes = await client.query(`
      SELECT r.id, r.name, r.is_boss_room, f.floor_number
      FROM rooms r
      JOIN floors f ON r.floor_id = f.id
      WHERE r.is_boss_room = true AND f.floor_number = 1
      LIMIT 1
    `);
    
    if (roomRes.rows.length === 0) {
      console.error('❌ Guardian room not found.');
      return;
    }
    const roomId = roomRes.rows[0].id;
    console.log(`✓ Found guardian room: ${roomRes.rows[0].name} (ID: ${roomId})`);
    
    // Unlock the room if not already unlocked
    const unlockCheckRes = await client.query(
      'SELECT * FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
      [userId, roomId]
    );
    
    if (unlockCheckRes.rows.length === 0) {
      await client.query(
        'INSERT INTO user_room_unlocks (user_id, room_id, unlocked_at, silk_spent) VALUES ($1, $2, NOW(), 0)',
        [userId, roomId]
      );
      console.log('✓ Guardian room unlocked!');
    } else {
      console.log('• Guardian room already unlocked');
    }
    
    // Mark the room as completed
    const completeRes = await client.query(
      'SELECT completed_at FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
      [userId, roomId]
    );
    
    if (!completeRes.rows[0].completed_at) {
      await client.query(
        'UPDATE user_room_unlocks SET completed_at = NOW() WHERE user_id = $1 AND room_id = $2',
        [userId, roomId]
      );
      console.log('✓ Guardian room marked as completed!');
    } else {
      console.log('• Guardian room already completed');
    }
    
    console.log('✅ Done!');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

unlockGuardianForMatthew();

