import { pool } from './server/src/db/index.js';
import fs from 'fs';

async function completeExport() {
  try {
    console.log('\n📤 Complete Database Export\n');
    
    const tablesWithData = [
      'vocab_entries',
      'word_timeline_events',
      'word_relations',
      'timeline_event_tags',
      'causal_tags',
      'quiz_materials',
      'quiz_questions',
      'story_comprehension_questions',
      'root_families',
      'word_root_links',
      'semantic_domains',
      'vocab_domain_links',
      'derivations',
      'citations',
      'maps',
      'floors',
      'rooms',
      'floor_boss_scenarios',
      'tokens'
    ];
    
    const sqlExports = [];
    
    for (const table of tablesWithData) {
      try {
        const { rows } = await pool.query(`SELECT COUNT(*) as count FROM ${table}`);
        const count = parseInt(rows[0].count);
        
        if (count > 0) {
          console.log(`📊 ${table}: ${count} rows`);
          
          const { rows: data } = await pool.query(`SELECT * FROM ${table}`);
          
          if (data.length > 0) {
            sqlExports.push(`\n-- ===========================================`);
            sqlExports.push(`-- ${table.toUpperCase()} (${count} rows)`);
            sqlExports.push(`-- ===========================================\n`);
            
            const columns = Object.keys(data[0]);
            
            for (const row of data) {
              const values = columns.map(col => {
                const val = row[col];
                if (val === null) return 'NULL';
                
                // Handle Date objects from PostgreSQL
                if (val && typeof val === 'object' && val.constructor && val.constructor.name === 'Date') {
                  return `'${val.toISOString()}'`;
                }
                
                // Handle other objects (JSONB)
                if (typeof val === 'object' && val !== null) {
                  return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
                }
                
                // Handle boolean
                if (typeof val === 'boolean') return val;
                
                // Handle string
                if (typeof val === 'string') {
                  return `'${String(val).replace(/'/g, "''")}'`;
                }
                
                return val;
              }).join(', ');
              
              // Determine ON CONFLICT behavior based on table
              let onConflict = '';
              const primaryKeys = {
                'vocab_entries': '(id)',
                'word_timeline_events': '(id)',
                'word_relations': '(id)',
                'timeline_event_tags': '(event_id, tag_id)',
                'causal_tags': '(id)',
                'quiz_materials': '(word_id, level)',
                'quiz_questions': '(id)',
                'story_comprehension_questions': '(word_id, century)',
                'root_families': '(id)',
                'word_root_links': '(word_id, root_id)',
                'semantic_domains': '(id)',
                'vocab_domain_links': '(word_id, domain_id)',
                'derivations': '(id)',
                'citations': '(id)',
                'maps': '(id)',
                'floors': '(map_id, floor_number)',
                'rooms': '(floor_id, room_number)',
                'floor_boss_scenarios': '(id)',
                'tokens': '(id)'
              };
              
              const key = primaryKeys[table] || '(id)';
              
              if (key === '(id)') {
                // For tables with single ID primary key
                onConflict = `ON CONFLICT ${key} DO UPDATE SET ${columns.filter(c => c !== 'id' && c !== 'created_at').map(c => `${c} = EXCLUDED.${c}`).join(', ')}`;
              } else {
                // For tables with composite keys
                onConflict = `ON CONFLICT ${key} DO UPDATE SET updated_at = EXCLUDED.updated_at WHERE ${key.split(',').map(k => k.trim().replace('(', '').replace(')', '')).map(k => `${k} = EXCLUDED.${k}`).join(' AND ')}`;
              }
              
              sqlExports.push(`INSERT INTO ${table} (${columns.join(', ')}) VALUES (${values}) ${onConflict};`);
            }
          }
        }
      } catch (error) {
        console.log(`⚠️  Skipping ${table}: ${error.message}`);
      }
    }
    
    const sqlFile = 'complete_database_export.sql';
    fs.writeFileSync(sqlFile, sqlExports.join('\n'));
    
    console.log(`\n✅ Complete export saved to: ${sqlFile}`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

completeExport();
