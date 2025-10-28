import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function importAllData() {
  try {
    console.log('🔄 Starting complete quiz import...\n');

    const rootDir = path.resolve(__dirname, '../..');
    
    // Import Week 1
    console.log('📅 WEEK 1 (2025.10.17)');
    const week1Path = path.join(rootDir, 'weekly_quizzes/2025.10.17_quiz.json');
    const week1Quiz = JSON.parse(fs.readFileSync(week1Path, 'utf8'));
    
    let w1Count = 0;
    for (const entry of week1Quiz) {
      // Get word_id from vocab_entries
      const wordRes = await pool.query(
        'SELECT id FROM vocab_entries WHERE word = $1',
        [entry.word]
      );
      
      if (wordRes.rows.length === 0) {
        console.log(`⚠️  Word "${entry.word}" not found, skipping`);
        continue;
      }
      
      const word_id = wordRes.rows[0].id;
      
      await pool.query(
        `INSERT INTO quiz_materials 
         (word_id, level, question_type, prompt, correct_answer, options, variant_data, reward_amount)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          word_id,
          entry.level,
          entry.question_type,
          entry.prompt,
          JSON.stringify(entry.correct_answer),
          entry.options ? JSON.stringify(entry.options) : null,
          entry.variant_data ? JSON.stringify(entry.variant_data) : null,
          entry.reward_amount
        ]
      );
      w1Count++;
    }
    console.log(`   ✓ Imported ${w1Count} quiz entries\n`);

    // Import Week 2
    console.log('📅 WEEK 2 (2025.10.25)');
    const week2Path = path.join(rootDir, 'weekly_quizzes/2025.10.25_quiz.json');
    const week2Quiz = JSON.parse(fs.readFileSync(week2Path, 'utf8'));
    
    let w2Count = 0;
    for (const entry of week2Quiz) {
      // Get word_id from vocab_entries
      const wordRes = await pool.query(
        'SELECT id FROM vocab_entries WHERE word = $1',
        [entry.word]
      );
      
      if (wordRes.rows.length === 0) {
        console.log(`⚠️  Word "${entry.word}" not found, skipping`);
        continue;
      }
      
      const word_id = wordRes.rows[0].id;
      
      await pool.query(
        `INSERT INTO quiz_materials 
         (word_id, level, question_type, prompt, correct_answer, options, variant_data, reward_amount)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          word_id,
          entry.level,
          entry.question_type,
          entry.prompt,
          JSON.stringify(entry.correct_answer),
          entry.options ? JSON.stringify(entry.options) : null,
          entry.variant_data ? JSON.stringify(entry.variant_data) : null,
          entry.reward_amount
        ]
      );
      w2Count++;
    }
    console.log(`   ✓ Imported ${w2Count} quiz entries\n`);

    // Verify
    const totalRes = await pool.query('SELECT COUNT(*) as count FROM quiz_materials');
    const byWordRes = await pool.query(
      `SELECT v.word, COUNT(*) as count 
       FROM quiz_materials qm
       JOIN vocab_entries v ON qm.word_id = v.id
       GROUP BY v.word 
       ORDER BY v.word`
    );

    console.log('✅ Import complete!');
    console.log(`   • Total entries in database: ${totalRes.rows[0].count}`);
    console.log(`   • Week 1: ${w1Count} entries`);
    console.log(`   • Week 2: ${w2Count} entries`);
    console.log(`   • Unique words: ${byWordRes.rows.length}`);
    console.log(`\n📊 Breakdown by word:`);
    for (const row of byWordRes.rows) {
      console.log(`   • ${row.word}: ${row.count} entries`);
    }

  } catch (error) {
    console.error('❌ Import error:', error);
  } finally {
    await pool.end();
  }
}

importAllData();
