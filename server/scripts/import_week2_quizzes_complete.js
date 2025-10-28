// Import quiz materials for week 2 words from levels_1-5_2025.10.25.json
import fs from 'fs';
import path from 'path';
import { pool } from '../src/db/index.js';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function importWeek2Quizzes() {
  try {
    // Read the quiz data
    // Go up from server/scripts to project root
    const rootDir = path.resolve(__dirname, '../..');
    const filePath = path.join(rootDir, 'weekly_quizzes/levels_1-5_2025.10.25.json');
    console.log('Reading file:', filePath);
    console.log('__dirname:', __dirname);
    console.log('rootDir:', rootDir);
    const rawData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    
    console.log(`\n📚 Importing ${rawData.length} quiz questions...\n`);
    
    let imported = 0;
    let updated = 0;
    let skipped = 0;
    
    for (const question of rawData) {
      try {
        let word_id;
        
        // If word_id is provided, use it; otherwise look up by word name
        if (question.word_id) {
          // Look up word name from word_id
          const nameRes = await pool.query(
            'SELECT word FROM vocab_entries WHERE id = $1',
            [question.word_id]
          );
          
          if (nameRes.rows.length === 0) {
            console.log(`⚠️  Word ID ${question.word_id} not found, skipping`);
            skipped++;
            continue;
          }
          
          word_id = question.word_id;
        } else if (question.word) {
          // Look up word_id from word name
          const wordRes = await pool.query(
            'SELECT id FROM vocab_entries WHERE word = $1',
            [question.word]
          );
          
          if (wordRes.rows.length === 0) {
            console.log(`⚠️  Word "${question.word}" not found, skipping`);
            skipped++;
            continue;
          }
          
          word_id = wordRes.rows[0].id;
        } else {
          console.log(`⚠️  Question missing both word and word_id, skipping`);
          skipped++;
          continue;
        }
        
        // Check if this specific question already exists
        const existingRes = await pool.query(
          'SELECT id FROM quiz_materials WHERE word_id = $1 AND level = $2 AND question_type = $3',
          [word_id, question.level, question.question_type]
        );
        
        // Parse options - the JSON might have different structures
        let optionsData = question.options;
        if (typeof question.incorrect_answers !== 'undefined') {
          // This is a definition question with the old format
          optionsData = {
            incorrect_answers: question.incorrect_answers,
            correct_answers: question.correct_answers
          };
        }
        
        if (existingRes.rows.length > 0) {
          // Update existing
          await pool.query(
            `UPDATE quiz_materials SET
              prompt = $4,
              options = $5,
              correct_answer = $6,
              variant_data = $7,
              reward_amount = $8,
              updated_at = NOW()
            WHERE word_id = $1 AND level = $2 AND question_type = $3`,
            [
              word_id,
              question.level,
              question.question_type,
              question.prompt,
              optionsData ? JSON.stringify(optionsData) : null,
              question.correct_answer || null,
              question.variant_data ? JSON.stringify(question.variant_data) : null,
              question.reward_amount || 10
            ]
          );
          console.log(`  ✓ Updated: ${question.word} - Level ${question.level} (${question.question_type})`);
          updated++;
        } else {
          // Insert new
          await pool.query(
            `INSERT INTO quiz_materials (
              word_id, level, question_type, prompt,
              options, correct_answer, variant_data, reward_amount
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
              word_id,
              question.level,
              question.question_type,
              question.prompt,
              optionsData ? JSON.stringify(optionsData) : null,
              question.correct_answer || null,
              question.variant_data ? JSON.stringify(question.variant_data) : null,
              question.reward_amount || 10
            ]
          );
          console.log(`  ✓ Imported: ${question.word} - Level ${question.level} (${question.question_type})`);
          imported++;
        }
      } catch (err) {
        console.error(`  ❌ Error importing ${question.word} Level ${question.level}:`, err.message);
      }
    }
    
    console.log(`\n✅ Import complete!`);
    console.log(`   Imported: ${imported}`);
    console.log(`   Updated: ${updated}`);
    console.log(`   Skipped: ${skipped}`);
    console.log(`   Total processed: ${imported + updated + skipped}\n`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

importWeek2Quizzes();

