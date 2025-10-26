import { pool } from './server/src/db/index.js';

async function checkFloors() {
  try {
    const result = await pool.query(`
      SELECT 
        f.id,
        f.map_id,
        f.floor_number,
        f.name,
        COUNT(r.id) as rooms
      FROM floors f
      LEFT JOIN rooms r ON r.floor_id = f.id
      GROUP BY f.id, f.map_id, f.floor_number, f.name
      ORDER BY f.map_id, f.floor_number
    `);
    
    console.log('\n📊 FLOORS AND ROOMS:');
    for (const row of result.rows) {
      console.log(`Floor ${row.floor_number}: ${row.name} - ${row.rooms} rooms (floor_id: ${row.id})`);
    }
    
    // Also check which words are assigned to rooms
    const roomWords = await pool.query(`
      SELECT r.room_number, r.name as room_name, v.word
      FROM rooms r
      JOIN vocab_entries v ON v.id = r.word_id
      ORDER BY r.floor_id, r.room_number
    `);
    
    console.log('\n📝 ROOMS WITH WORDS:');
    for (const row of roomWords.rows) {
      console.log(`  Room ${row.room_number}: ${row.room_name} - Word: ${row.word}`);
    }
    
  } catch (error) {
    console.error('Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

checkFloors();

