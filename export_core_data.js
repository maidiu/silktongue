import { pool } from './server/src/db/index.js';
import fs from 'fs';

async function exportCoreData() {
  try {
    console.log('\n📤 Exporting CORE data from Local Database\n');
    
    // Only export tables that we know match the VPS schema
    const coreTables = ['vocab_entries', 'quiz_materials', 'story_comprehension_questions'];
    const towerTables = ['maps', 'floors', 'rooms'];
    
    const sqlExports = [];
    
    // Export vocab
    console.log('📊 Exporting vocab_entries...');
    const { rows: vocabData } = await pool.query(`SELECT * FROM vocab_entries ORDER BY id`);
    sqlExports.push(`\n-- ===========================================`);
    sqlExports.push(`-- VOCAB_ENTRIES (${vocabData.length} rows)`);
    sqlExports.push(`-- ===========================================\n`);
    
    for (const row of vocabData) {
      const columns = Object.keys(row).filter(c => !['created_at'].includes(c));
      const arrayCols = ['synonyms', 'antonyms', 'variant_forms', 'english_synonyms', 'english_antonyms', 'french_synonyms', 'french_root_cognates', 'russian_synonyms', 'russian_root_cognates', 'common_collocations', 'common_phrases', 'sibling_words'];
      
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (val && typeof val === 'object' && val.constructor && val.constructor.name === 'Date') {
          return `'${val.toISOString()}'`;
        }
        // Handle arrays (text[])
        if (Array.isArray(val)) {
          const escaped = val.map(v => `"${String(v).replace(/"/g, '""')}"`).join(',');
          return `ARRAY[${escaped}]`;
        }
        if (typeof val === 'object' && val !== null) {
          return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
        }
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') {
          return `'${String(val).replace(/'/g, "''")}'`;
        }
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO vocab_entries (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (id) DO UPDATE SET ${columns.filter(c => c !== 'id').map(c => `${c} = EXCLUDED.${c}`).join(', ')};`);
    }
    
    // Export quizzes
    console.log('📊 Exporting quiz_materials...');
    const { rows: quizData } = await pool.query(`SELECT * FROM quiz_materials ORDER BY word_id, level`);
    sqlExports.push(`\n-- ===========================================`);
    sqlExports.push(`-- QUIZ_MATERIALS (${quizData.length} rows)`);
    sqlExports.push(`-- ===========================================\n`);
    
    for (const row of quizData) {
      const columns = Object.keys(row).filter(c => !['created_at', 'updated_at'].includes(c));
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (val && typeof val === 'object' && val.constructor && val.constructor.name === 'Date') {
          return `'${val.toISOString()}'`;
        }
        if (typeof val === 'object' && val !== null) {
          return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
        }
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') {
          return `'${String(val).replace(/'/g, "''")}'`;
        }
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO quiz_materials (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (word_id, level) DO UPDATE SET ${columns.filter(c => c !== 'word_id' && c !== 'level').map(c => `${c} = EXCLUDED.${c}`).join(', ')};`);
    }
    
    // Export story questions
    console.log('📊 Exporting story_comprehension_questions...');
    const { rows: storyData } = await pool.query(`SELECT * FROM story_comprehension_questions ORDER BY word_id, century`);
    sqlExports.push(`\n-- ===========================================`);
    sqlExports.push(`-- STORY_COMPREHENSION_QUESTIONS (${storyData.length} rows)`);
    sqlExports.push(`-- ===========================================\n`);
    
    for (const row of storyData) {
      const columns = Object.keys(row).filter(c => !['created_at', 'updated_at'].includes(c));
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (val && typeof val === 'object' && val.constructor && val.constructor.name === 'Date') {
          return `'${val.toISOString()}'`;
        }
        if (typeof val === 'object' && val !== null) {
          return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
        }
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') {
          return `'${String(val).replace(/'/g, "''")}'`;
        }
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO story_comprehension_questions (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (word_id, century) DO UPDATE SET question = EXCLUDED.question, options = EXCLUDED.options, correct_answer = EXCLUDED.correct_answer, explanation = EXCLUDED.explanation;`);
    }
    
    // Export tower data (maps, floors, rooms)
    console.log('📊 Exporting tower data...');
    const { rows: mapData } = await pool.query(`SELECT * FROM maps`);
    sqlExports.push(`\n-- ===========================================`);
    sqlExports.push(`-- MAPS (${mapData.length} rows)`);
    sqlExports.push(`-- ===========================================\n`);
    
    for (const row of mapData) {
      const columns = Object.keys(row).filter(c => !['created_at'].includes(c));
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') return `'${String(val).replace(/'/g, "''")}'`;
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO maps (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (id) DO NOTHING;`);
    }
    
    const { rows: floorData } = await pool.query(`SELECT * FROM floors ORDER BY map_id, floor_number`);
    sqlExports.push(`\n-- FLOORS (${floorData.length} rows)\n`);
    
    for (const row of floorData) {
      const columns = Object.keys(row).filter(c => !['created_at'].includes(c));
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') return `'${String(val).replace(/'/g, "''")}'`;
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO floors (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (map_id, floor_number) DO NOTHING;`);
    }
    
    const { rows: roomData } = await pool.query(`SELECT * FROM rooms ORDER BY floor_id, room_number`);
    sqlExports.push(`\n-- ROOMS (${roomData.length} rows)\n`);
    
    for (const row of roomData) {
      const columns = Object.keys(row).filter(c => !['created_at'].includes(c));
      const values = columns.map(col => {
        const val = row[col];
        if (val === null) return 'NULL';
        if (typeof val === 'boolean') return val;
        if (typeof val === 'string') return `'${String(val).replace(/'/g, "''")}'`;
        return val;
      }).join(', ');
      
      sqlExports.push(`INSERT INTO rooms (${columns.join(', ')}) VALUES (${values}) ON CONFLICT (floor_id, room_number) DO NOTHING;`);
    }
    
    const sqlFile = 'core_data_export.sql';
    fs.writeFileSync(sqlFile, sqlExports.join('\n'));
    
    console.log(`\n✅ Core data exported to: ${sqlFile}`);
    console.log(`   - ${vocabData.length} vocab entries`);
    console.log(`   - ${quizData.length} quiz questions`);
    console.log(`   - ${storyData.length} story questions`);
    console.log(`   - ${mapData.length} maps`);
    console.log(`   - ${floorData.length} floors`);
    console.log(`   - ${roomData.length} rooms`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

exportCoreData();
