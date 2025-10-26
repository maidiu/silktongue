import { pool } from './server/src/db/index.js';

async function initTower() {
  try {
    console.log('\n🏗️  INITIALIZING THE TOWER OF WORDS\n');
    
    // Create the main map
    const { rows: mapRows } = await pool.query(`
      INSERT INTO maps (name, description, total_floors)
      VALUES ('The Tower of Words', 'A journey through the lexicon, floor by floor, word by word.', 2)
      ON CONFLICT DO NOTHING
      RETURNING id
    `);
    
    let mapId;
    if (mapRows.length > 0) {
      mapId = mapRows[0].id;
    } else {
      const { rows } = await pool.query('SELECT id FROM maps WHERE name = $1', ['The Tower of Words']);
      mapId = rows[0].id;
    }
    
    console.log(`✓ Using Map ID: ${mapId}\n`);
    
    // Get all vocabulary words
    const { rows: vocabRows } = await pool.query(`
      SELECT id, word FROM vocab_entries 
      ORDER BY id
    `);
    
    console.log(`Found ${vocabRows.length} words total`);
    
    if (vocabRows.length === 0) {
      console.log('❌ No words found in the database');
      return;
    }
    
    // Split words into floors (8 words per floor)
    const wordsPerFloor = 8;
    const totalFloors = Math.ceil(vocabRows.length / wordsPerFloor);
    
    // Update map floors
    await pool.query('UPDATE maps SET total_floors = $1 WHERE id = $2', [totalFloors, mapId]);
    
    // Create floors
    for (let floorNum = 1; floorNum <= totalFloors; floorNum++) {
      const startIdx = (floorNum - 1) * wordsPerFloor;
      const endIdx = Math.min(startIdx + wordsPerFloor, vocabRows.length);
      const floorWords = vocabRows.slice(startIdx, endIdx);
      
      console.log(`\n📍 Setting up Floor ${floorNum} (${floorWords.length} words)`);
      
      // Create floor
      const { rows: floorRows } = await pool.query(`
        INSERT INTO floors (map_id, floor_number, name, description, silk_reward)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (map_id, floor_number) DO UPDATE SET updated_at = NOW()
        RETURNING id
      `, [
        mapId,
        floorNum,
        `Floor ${floorNum}: ${floorWords[0].word} and Companions`,
        `Eight powerful words await mastery on this floor.`,
        100 + (floorNum * 50)
      ]);
      
      const floorId = floorRows[0].id;
      console.log(`✓ Created Floor ${floorNum} (id: ${floorId})`);
      
      // Clear any existing rooms on this floor
      await pool.query('DELETE FROM rooms WHERE floor_id = $1', [floorId]);
      
      // Create rooms for each word
      for (let i = 0; i < floorWords.length; i++) {
        const word = floorWords[i];
        const roomNumber = i + 1;
        const isBoss = roomNumber === floorWords.length;
        
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
          `The Room of ${word.word}`,
          `Master ${word.word} and unlock its power.`,
          30 + (roomNumber * 10) + (floorNum * 20), // Progressive cost
          20 + (roomNumber * 5) + (floorNum * 10),  // Progressive reward
          isBoss
        ]);
        
        const badge = isBoss ? '👑' : '  ';
        console.log(`${badge} Room ${roomNumber}: ${word.word}`);
      }
    }
    
    console.log(`\n✅ TOWER INITIALIZATION COMPLETE`);
    console.log(`   - Map: "The Tower of Words"`);
    console.log(`   - Floors: ${totalFloors}`);
    console.log(`   - Total Words: ${vocabRows.length}`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

initTower();
