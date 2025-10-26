import { pool } from '../src/db/index.js';

async function fixBossRoom() {
  try {
    console.log('Fixing boss room assignment...');
    
    // Find verisimilitude room
    const findQuery = `
      SELECT id, room_number, name, is_boss_room, word_id
      FROM rooms
      WHERE name LIKE '%verisimilitude%'
    `;
    
    const { rows } = await pool.query(findQuery);
    
    if (rows.length === 0) {
      console.log('No verisimilitude room found');
      return;
    }
    
    console.log('Found verisimilitude room:', rows[0]);
    
    // Update to NOT be a boss room
    const updateQuery = `
      UPDATE rooms
      SET is_boss_room = false
      WHERE id = $1
    `;
    
    await pool.query(updateQuery, [rows[0].id]);
    
    console.log('✅ Updated verisimilitude room to not be a boss room');
    
    // Check if there's already a floor guardian room
    const guardianQuery = `
      SELECT id, room_number, name, is_boss_room
      FROM rooms
      WHERE is_boss_room = true
    `;
    
    const { rows: guardianRows } = await pool.query(guardianQuery);
    
    if (guardianRows.length === 0) {
      console.log('⚠️ No floor guardian room exists. You may need to create one.');
    } else {
      console.log('✅ Floor guardian room exists:', guardianRows);
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

fixBossRoom();

