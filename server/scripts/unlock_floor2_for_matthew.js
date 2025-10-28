import { pool } from '../src/db/index.js';

async function unlockFloor2ForMatthew() {
  try {
    console.log('🔓 Unlocking Floor 2 for Matthew...');
    
    // Find Matthew
    const { rows: userRows } = await pool.query(
      "SELECT id, username FROM users WHERE username = 'Matthew'"
    );
    
    if (userRows.length === 0) {
      console.error('❌ User Matthew not found');
      await pool.end();
      return;
    }
    
    const user = userRows[0];
    console.log(`✓ Found user: ${user.username} (id: ${user.id})`);
    
    // Get Floor 2
    const { rows: floorRows } = await pool.query(
      'SELECT * FROM floors WHERE floor_number = 2'
    );
    
    if (floorRows.length === 0) {
      console.error('❌ Floor 2 not found');
      await pool.end();
      return;
    }
    
    const floor2 = floorRows[0];
    console.log(`✓ Found Floor 2: ${floor2.name} (id: ${floor2.id})`);
    
    // Update user progress to Floor 2
    await pool.query(`
      INSERT INTO user_map_progress (user_id, map_id, current_floor)
      VALUES ($1, $2, 2)
      ON CONFLICT (user_id, map_id)
      DO UPDATE SET current_floor = 2, updated_at = NOW()
    `, [user.id, floor2.map_id]);
    
    console.log('✅ User progress updated to Floor 2');
    
    // Get Floor 2 rooms and unlock the first one (attest) for testing
    const { rows: roomRows } = await pool.query(
      'SELECT * FROM rooms WHERE floor_id = $1 ORDER BY room_number LIMIT 1',
      [floor2.id]
    );
    
    if (roomRows.length > 0) {
      const firstRoom = roomRows[0];
      
      const { rows: roomUnlockRows } = await pool.query(
        'SELECT * FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
        [user.id, firstRoom.id]
      );
      
      if (roomUnlockRows.length === 0) {
        await pool.query(
          'INSERT INTO user_room_unlocks (user_id, room_id, silk_spent) VALUES ($1, $2, 0)',
          [user.id, firstRoom.id]
        );
        console.log(`✅ Unlocked first room on Floor 2: ${firstRoom.name}`);
      } else {
        console.log(`✓ First room already unlocked: ${firstRoom.name}`);
      }
    }
    
    // Also unlock the Guardian room
    const { rows: guardianRoomRows } = await pool.query(
      'SELECT * FROM rooms WHERE floor_id = $1 AND is_boss_room = true',
      [floor2.id]
    );
    
    if (guardianRoomRows.length > 0) {
      const guardianRoom = guardianRoomRows[0];
      
      const { rows: guardianUnlockRows } = await pool.query(
        'SELECT * FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
        [user.id, guardianRoom.id]
      );
      
      if (guardianUnlockRows.length === 0) {
        await pool.query(
          'INSERT INTO user_room_unlocks (user_id, room_id, silk_spent, completed_at) VALUES ($1, $2, 0, NOW())',
          [user.id, guardianRoom.id]
        );
        console.log(`✅ Unlocked and completed Guardian room on Floor 2`);
      } else if (!guardianUnlockRows[0].completed_at) {
        await pool.query(
          'UPDATE user_room_unlocks SET completed_at = NOW() WHERE user_id = $1 AND room_id = $2',
          [user.id, guardianRoom.id]
        );
        console.log(`✅ Marked Guardian room as completed`);
      } else {
        console.log(`✓ Guardian room already completed`);
      }
    }
    
    console.log('\n🎉 Done! Matthew can now access Floor 2.');
    
    await pool.end();
  } catch (error) {
    console.error('❌ Error:', error);
    await pool.end();
    process.exit(1);
  }
}

unlockFloor2ForMatthew();

