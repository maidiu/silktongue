import { pool } from '../src/db/index.js';

async function unlockFirstWord() {
  try {
    console.log('🔓 Unlocking "inherent" for all users...\n');

    // Find the room for "inherent"
    const { rows: roomRows } = await pool.query(`
      SELECT r.id, r.name, ve.word
      FROM rooms r
      JOIN vocab_entries ve ON r.word_id = ve.id
      WHERE ve.word = 'inherent'
      ORDER BY r.room_number
      LIMIT 1
    `);

    if (roomRows.length === 0) {
      console.log('❌ Room for "inherent" not found');
      await pool.end();
      return;
    }

    const room = roomRows[0];
    console.log(`✓ Found room: ${room.name} (ID: ${room.id}) for word: ${room.word}\n`);

    // Get all users
    const { rows: users } = await pool.query('SELECT id, username FROM users');

    console.log(`📊 Found ${users.length} users\n`);

    let unlocked = 0;
    let alreadyUnlocked = 0;

    for (const user of users) {
      // Check if already unlocked
      const { rows: checkRows } = await pool.query(
        'SELECT id FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
        [user.id, room.id]
      );

      if (checkRows.length > 0) {
        alreadyUnlocked++;
        console.log(`  ⊙ ${user.username}: already unlocked`);
        continue;
      }

      // Unlock the room (no silk cost)
      await pool.query(
        'INSERT INTO user_room_unlocks (user_id, room_id, silk_spent, unlocked_at) VALUES ($1, $2, 0, NOW())',
        [user.id, room.id]
      );
      unlocked++;
      console.log(`  ✓ Unlocked for ${user.username}`);
    }

    console.log(`\n✅ Complete!`);
    console.log(`   • Newly unlocked: ${unlocked}`);
    console.log(`   • Already unlocked: ${alreadyUnlocked}`);
    console.log(`   • Total processed: ${users.length}`);

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

unlockFirstWord();
