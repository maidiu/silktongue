import { pool } from './server/src/db/index.js';

async function setupFloor2() {
  try {
    console.log('\n🏗️  SETTING UP FLOOR 2 FOR 8 NEW WORDS\n');
    
    // Get words from the 2025.10.25 entries
    const { rows: wordRows } = await pool.query(`
      SELECT id, word FROM vocab_entries 
      WHERE date_added >= '2025-10-25' 
      ORDER BY id
    `);
    
    console.log(`Found ${wordRows.length} words for Floor 2:`);
    wordRows.forEach(w => console.log(`  - ${w.word} (id: ${w.id})`));
    
    if (wordRows.length === 0) {
      console.log('❌ No words found for Floor 2');
      return;
    }
    
    // Get the map ID
    const { rows: mapRows } = await pool.query('SELECT id FROM maps WHERE id = 3');
    const mapId = mapRows[0].id;
    console.log(`\n📍 Using Map ID: ${mapId}`);
    
    // Create Floor 2
    const { rows: floorRows } = await pool.query(`
      INSERT INTO floors (map_id, floor_number, name, description, silk_reward)
      VALUES ($1, 2, 'The Second Chamber', 'Eight powerful words await mastery on this floor...', 150)
      ON CONFLICT (map_id, floor_number) DO UPDATE SET updated_at = NOW()
      RETURNING id
    `, [mapId]);
    
    const floorId = floorRows[0].id;
    console.log(`✓ Created Floor 2 (id: ${floorId})`);
    
    // Clear any existing rooms on Floor 2
    await pool.query('DELETE FROM rooms WHERE floor_id = $1', [floorId]);
    console.log('✓ Cleared existing Floor 2 rooms');
    
    // Create rooms for each word
    for (let i = 0; i < wordRows.length; i++) {
      const word = wordRows[i];
      const roomNumber = i + 1;
      
      const { rows } = await pool.query(`
        INSERT INTO rooms (
          floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
      `, [
        floorId,
        roomNumber,
        word.id,
        `Room of ${word.word}`,
        `Master ${word.word} and unlock its power.`,
        50 + (roomNumber * 10), // Progressive cost
        25 + (roomNumber * 5),  // Progressive reward
        roomNumber === wordRows.length // Last room is boss
      ]);
      
      console.log(`✓ Created room ${roomNumber}: ${word.word} (room_id: ${rows[0].id})`);
    }
    
    console.log('\n✅ FLOOR 2 SETUP COMPLETE');
    console.log(`   - Floor: 2 (${wordRows.length} rooms)`);
    console.log(`   - Boss Room: ${wordRows[wordRows.length - 1].word}`);
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

setupFloor2();
