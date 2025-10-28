import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function revertSettingsToSimpleLabels() {
  try {
    console.log('🔄 Reverting settings to simple labels from source quiz files...\n');
    
    // Load the source quiz files
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const week1Quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    const week2Quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    const allQuizzes = [...week1Quizzes, ...week2Quizzes];
    
    // Filter for level 5 and 6 quizzes (which have settings)
    const level5and6 = allQuizzes.filter(q => (q.level === 5 || q.level === 6) && q.options?.settings);
    
    console.log(`Found ${level5and6.length} quizzes with settings\n`);
    
    let updated = 0;
    
    for (const quiz of level5and6) {
      const { word, word_id, level, options } = quiz;
      
      if (!options || !options.settings) continue;
      
      console.log(`  ✓ Updating ${word || 'word_id ' + word_id} Level ${level}`);
      
      // The settings from the source file are already the simple labels we want
      // Just update them in the database
      await pool.query(`
        UPDATE quiz_materials 
        SET options = $1
        WHERE word_id = $2 AND level = $3
      `, [JSON.stringify(options), word_id, level]);
      
      updated++;
    }
    
    console.log(`\n✅ Updated ${updated} quizzes in database with simple setting labels`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

revertSettingsToSimpleLabels();

