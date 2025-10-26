import { pool } from './server/src/db/index.js';
import fs from 'fs';

async function exportTowerData() {
  try {
    console.log('\n📤 Exporting Tower Data from Database\n');
    
    // Get all words
    const { rows: vocabRows } = await pool.query(`
      SELECT id, word FROM vocab_entries ORDER BY id
    `);
    
    console.log(`Found ${vocabRows.length} words\n`);
    
    // Group into floors (8 per floor)
    const wordsPerFloor = 8;
    const sqlCommands = [];
    
    sqlCommands.push(`-- Tower of Words Data Export`);
    sqlCommands.push(`-- Generated on ${new Date().toISOString()}\n`);
    
    // Create the map
    sqlCommands.push(`-- Create the main map`);
    sqlCommands.push(`INSERT INTO maps (id, name, description, total_floors, created_at)`);
    sqlCommands.push(`VALUES (1, 'The Tower of Words', 'A journey through the lexicon, floor by floor, word by word.', ${Math.ceil(vocabRows.length / wordsPerFloor)}, NOW())`);
    sqlCommands.push(`ON CONFLICT (id) DO UPDATE SET total_floors = EXCLUDED.total_floors;\n\n`);
    
    // Process each floor
    for (let floorNum = 1; floorNum <= Math.ceil(vocabRows.length / wordsPerFloor); floorNum++) {
      const startIdx = (floorNum - 1) * wordsPerFloor;
      const endIdx = Math.min(startIdx + wordsPerFloor, vocabRows.length);
      const floorWords = vocabRows.slice(startIdx, endIdx);
      
      console.log(`Floor ${floorNum}: ${floorWords.map(w => w.word).join(', ')}`);
      
      // Create floor
      sqlCommands.push(`-- Floor ${floorNum}: ${floorWords[0].word} and Companions`);
      sqlCommands.push(`INSERT INTO floors (map_id, floor_number, name, description, silk_reward, created_at)`);
      sqlCommands.push(`VALUES (1, ${floorNum}, 'Floor ${floorNum}: ${floorWords[0].word} and Companions', 'Eight powerful words await mastery on this floor...', ${100 + (floorNum * 50)}, NOW())`);
      sqlCommands.push(`ON CONFLICT (map_id, floor_number) DO NOTHING;\n`);
      
      // Create rooms
      floorWords.forEach((word, idx) => {
        const isBoss = idx === floorWords.length - 1;
        sqlCommands.push(`INSERT INTO rooms (floor_id, room_number, word_id, name, description, silk_cost, silk_reward, is_boss_room, created_at)`);
        sqlCommands.push(`SELECT (SELECT id FROM floors WHERE map_id = 1 AND floor_number = ${floorNum}), ${idx + 1}, ${word.id}, 'The Room of ${word.word}', 'Master ${word.word} and unlock its power.', ${40 + (idx * 10) + (floorNum * 20)}, ${30 + (idx * 5) + (floorNum * 10)}, ${isBoss}, NOW()`);
        sqlCommands.push(`ON CONFLICT (floor_id, room_number) DO UPDATE SET word_id = EXCLUDED.word_id, name = EXCLUDED.name, description = EXCLUDED.description, silk_cost = EXCLUDED.silk_cost, silk_reward = EXCLUDED.silk_reward, is_boss_room = EXCLUDED.is_boss_room;`);
      });
      
      sqlCommands.push('');
    }
    
    // Write to file
    const sqlFile = 'tower_data_export.sql';
    fs.writeFileSync(sqlFile, sqlCommands.join('\n'));
    
    console.log(`\n✅ Tower data exported to: ${sqlFile}`);
    console.log(`   - ${Math.ceil(vocabRows.length / wordsPerFloor)} floors`);
    console.log(`   - ${vocabRows.length} rooms total`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

exportTowerData();
