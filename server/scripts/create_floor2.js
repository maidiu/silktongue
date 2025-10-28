import { pool } from '../src/db/index.js';

async function createFloor2() {
  try {
    console.log('🏗️  Creating Floor 2...');
    
    // Check existing floors
    const { rows: floors } = await pool.query('SELECT * FROM floors ORDER BY floor_number');
    console.log(`\nExisting floors: ${floors.length}`);
    floors.forEach(f => console.log(`  - Floor ${f.floor_number}: ${f.name} (id: ${f.id})`));
    
    // Check if floor 2 already exists
    const floor2Exists = floors.some(f => f.floor_number === 2);
    if (floor2Exists) {
      console.log('\n✅ Floor 2 already exists!');
      await pool.end();
      return;
    }
    
    // Get the map_id from floor 1
    const mapId = floors[0].map_id;
    console.log(`\nUsing map_id: ${mapId}`);
    
    // Get Week 2 words
    const week2WordsList = ['attest', 'pall', 'lumbering', 'scurry', 'steadfast', 'elucidate', 'plausible', 'ubiquitous'];
    const { rows: week2Words } = await pool.query(`
      SELECT id, word 
      FROM vocab_entries 
      WHERE word = ANY($1)
      ORDER BY word
    `, [week2WordsList]);
    
    console.log(`\nWeek 2 words found: ${week2Words.length}`);
    week2Words.forEach(w => console.log(`  - ${w.word} (id: ${w.id})`));
    
    if (week2Words.length === 0) {
      console.error('❌ No Week 2 words found! Cannot create Floor 2.');
      await pool.end();
      return;
    }
    
    // Create Floor 2
    const { rows: newFloorRows } = await pool.query(`
      INSERT INTO floors (map_id, floor_number, name, description, unlock_requirement, silk_reward)
      VALUES ($1, 2, 'The Archives', 
        'The second floor holds deeper mysteries. Eight new words await mastery, each unlocking greater understanding of the world''s hidden nature.',
        'Complete Floor 1 Guardian Challenge',
        200)
      RETURNING *
    `, [mapId]);
    
    const floor2 = newFloorRows[0];
    console.log(`\n✅ Created Floor 2: ${floor2.name} (id: ${floor2.id})`);
    
    // Create 8 rooms + 1 guardian room for Floor 2
    console.log('\n📦 Creating rooms for Floor 2...');
    
    for (let i = 0; i < week2Words.length; i++) {
      const word = week2Words[i];
      const roomNumber = i + 1;
      
      await pool.query(`
        INSERT INTO rooms (floor_id, room_number, name, description, silk_cost, silk_reward, is_boss_room, word_id)
        VALUES ($1, $2, $3, $4, $5, $6, false, $7)
      `, [
        floor2.id,
        roomNumber,
        `Room of ${word.word.charAt(0).toUpperCase() + word.word.slice(1)}`,
        `Master the word "${word.word}" through story, quiz, and challenge.`,
        10, // silk_cost
        15, // silk_reward
        word.id
      ]);
      
      console.log(`  ✓ Room ${roomNumber}: ${word.word}`);
    }
    
    // Create Guardian room
    await pool.query(`
      INSERT INTO rooms (floor_id, room_number, name, description, silk_cost, silk_reward, is_boss_room, word_id)
      VALUES ($1, 9, 'Floor Guardian Chamber', 
        'The guardian of this floor awaits. Only those who have mastered all eight words may proceed.',
        0, 0, true, NULL)
    `, [floor2.id]);
    
    console.log(`  ✓ Room 9: Guardian Chamber (boss room)`);
    
    console.log('\n🎉 Floor 2 created successfully!');
    
    // Show final summary
    const { rows: allFloors } = await pool.query('SELECT * FROM floors ORDER BY floor_number');
    const { rows: allRooms } = await pool.query(`
      SELECT r.*, ve.word, f.floor_number 
      FROM rooms r 
      LEFT JOIN vocab_entries ve ON r.word_id = ve.id
      JOIN floors f ON r.floor_id = f.id
      ORDER BY f.floor_number, r.room_number
    `);
    
    console.log('\n📊 Final Summary:');
    allFloors.forEach(f => {
      const floorRooms = allRooms.filter(r => r.floor_number === f.floor_number);
      console.log(`\nFloor ${f.floor_number}: ${f.name}`);
      floorRooms.forEach(r => {
        console.log(`  - Room ${r.room_number}: ${r.word || 'Guardian'} ${r.is_boss_room ? '(BOSS)' : ''}`);
      });
    });
    
    await pool.end();
  } catch (error) {
    console.error('❌ Error creating Floor 2:', error);
    await pool.end();
    process.exit(1);
  }
}

createFloor2();

