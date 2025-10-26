import { pool } from '../src/db/index.js';

async function createFloorGuardian() {
  try {
    console.log('Creating floor guardian room...');
    
    // Get the floor ID for floor 1
    const floorQuery = `
      SELECT id
      FROM floors
      WHERE map_id = 3 AND floor_number = 1
    `;
    
    const { rows: floorRows } = await pool.query(floorQuery);
    
    if (floorRows.length === 0) {
      console.log('❌ Floor not found');
      return;
    }
    
    const floorId = floorRows[0].id;
    console.log('Found floor ID:', floorId);
    
    // Get the next room number
    const maxRoomQuery = `
      SELECT MAX(room_number) as max_room
      FROM rooms
      WHERE floor_id = $1
    `;
    
    const { rows: maxRows } = await pool.query(maxRoomQuery, [floorId]);
    const nextRoomNumber = (maxRows[0].max_room || 0) + 1;
    
    console.log('Next room number:', nextRoomNumber);
    
    // Create the floor guardian room
    const insertQuery = `
      INSERT INTO rooms (
        floor_id, room_number, name, description, 
        silk_cost, silk_reward, is_boss_room
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id
    `;
    
    const { rows } = await pool.query(insertQuery, [
      floorId,
      nextRoomNumber,
      'Floor Guardian Chamber',
      'Only those with the language to describe the world to come will be admitted to go on—those who are worthy, those who are equipped for future battle, those who know the true names of things.',
      0, // No cost to attempt
      100, // Bonus reward for completing
      true // Is boss room
    ]);
    
    console.log('✅ Created floor guardian room:', rows[0]);
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

createFloorGuardian();

