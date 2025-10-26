import { pool } from '../src/db/index.js';

async function checkTable() {
  try {
    console.log('Checking word_timeline_events table...');
    
    // Check if table exists and get its structure
    const query = `
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'word_timeline_events'
      ORDER BY ordinal_position;
    `;
    
    const { rows } = await pool.query(query);
    
    if (rows.length === 0) {
      console.log('❌ Table word_timeline_events does not exist');
    } else {
      console.log('✅ Table word_timeline_events exists with columns:');
      rows.forEach(row => {
        console.log(`  - ${row.column_name}: ${row.data_type}`);
      });
    }
    
    // Check if there are any existing records
    const countQuery = 'SELECT COUNT(*) FROM word_timeline_events';
    const { rows: countRows } = await pool.query(countQuery);
    console.log(`\nCurrent records in table: ${countRows[0].count}`);
    
  } catch (error) {
    console.error('Error checking table:', error);
  } finally {
    await pool.end();
  }
}

checkTable();
