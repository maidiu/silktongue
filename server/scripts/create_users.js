import bcrypt from 'bcrypt';
import { pool } from '../src/db/index.js';

async function createUsers() {
  try {
    // Hash passwords
    const maxPassword = await bcrypt.hash('maximillian', 10);
    const sergeiPassword = await bcrypt.hash('sergio', 10);
    const matthewPassword = await bcrypt.hash('maidiu', 10);

    // Insert users
    const maxResult = await pool.query(
      'INSERT INTO users (username, password_hash, silk_balance, health_points) VALUES ($1, $2, $3, $4) ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id, username',
      ['Max', maxPassword, 0, 5]
    );

    const sergeiResult = await pool.query(
      'INSERT INTO users (username, password_hash, silk_balance, health_points) VALUES ($1, $2, $3, $4) ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id, username',
      ['Sergei', sergeiPassword, 0, 5]
    );

    const matthewResult = await pool.query(
      'INSERT INTO users (username, password_hash, silk_balance, health_points) VALUES ($1, $2, $3, $4) ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id, username',
      ['Matthew', matthewPassword, 0, 5]
    );

    console.log('✅ Created users:');
    console.log(`   Max (ID: ${maxResult.rows[0].id}) - Password: maximillian`);
    console.log(`   Sergei (ID: ${sergeiResult.rows[0].id}) - Password: sergio`);
    console.log(`   Matthew (ID: ${matthewResult.rows[0].id}) - Password: maidiu`);

  } catch (error) {
    console.error('❌ Error creating users:', error);
  } finally {
    await pool.end();
  }
}

createUsers();
