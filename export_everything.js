import { pool } from './server/src/db/index.js';
import fs from 'fs';

async function exportEverything() {
  try {
    console.log('\n📤 Exporting ALL Data from Local Database\n');
    
    // Get all tables
    const { rows: tables } = await pool.query(`
      SELECT tablename FROM pg_tables 
      WHERE schemaname = 'public' 
      ORDER BY tablename
    `);
    
    console.log(`Found ${tables.length} tables in database\n`);
    
    const exports = {};
    
    for (const { tablename } of tables) {
      try {
        const { rows } = await pool.query(`SELECT COUNT(*) as count FROM ${tablename}`);
        const count = parseInt(rows[0].count);
        
        if (count > 0) {
          console.log(`📊 ${tablename}: ${count} rows`);
          
          // Export the data
          const { rows: data } = await pool.query(`SELECT * FROM ${tablename}`);
          
          exports[tablename] = {
            count,
            data,
            columns: Object.keys(data[0] || {})
          };
        }
      } catch (error) {
        console.log(`⚠️  Skipping ${tablename}: ${error.message}`);
      }
    }
    
    console.log(`\n✅ Exported data from ${Object.keys(exports).length} tables`);
    console.log('\n📋 Summary:');
    for (const [table, info] of Object.entries(exports)) {
      console.log(`   ${table}: ${info.count} rows`);
    }
    
    // Save to JSON for inspection
    fs.writeFileSync('database_export.json', JSON.stringify(exports, null, 2));
    console.log('\n✅ Saved detailed export to: database_export.json');
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

exportEverything();
