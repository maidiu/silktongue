import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function fixQuizSettings() {
  try {
    // Load vocab entries to get the actual context data
    const week1Path = path.join(__dirname, '../../weekly_entries/2025.10.17.json');
    const week2Path = path.join(__dirname, '../../weekly_entries/2025.10.25.json');
    
    const week1Data = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    const week2Data = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    const allVocabEntries = [...week1Data, ...week2Data];
    
    console.log(`Loaded ${allVocabEntries.length} vocab entries`);
    
    // For each vocab entry, find the level 5 and level 6 quizzes and fix the settings
    for (const vocabEntry of allVocabEntries) {
      const { word, story } = vocabEntry;
      
      if (!story || story.length === 0) {
        console.log(`⚠️  No story for word: ${word}`);
        continue;
      }
      
      console.log(`\n🔄 Processing ${word}...`);
      
      // Get word_id from database
      const wordResult = await pool.query(
        'SELECT id FROM vocab_entries WHERE word = $1',
        [word]
      );
      
      if (wordResult.rows.length === 0) {
        console.log(`  ❌ Word not found in database: ${word}`);
        continue;
      }
      
      const wordId = wordResult.rows[0].id;
      
      // Extract real contexts from story array
      const realSettings = story.map(turn => {
        // Extract a clean excerpt from the context field
        // Limit to ~80-100 characters for readability
        let context = turn.context || '';
        if (context.length > 100) {
          // Find the last space before 100 chars to avoid cutting mid-word
          const lastSpace = context.lastIndexOf(' ', 100);
          context = context.substring(0, lastSpace > 0 ? lastSpace : 100) + '...';
        }
        return context;
      });
      
      console.log(`  ✓ Extracted ${realSettings.length} real settings`);
      
      // Update level 5 (story_reorder) quiz
      const level5Result = await pool.query(
        'SELECT id, options FROM quiz_materials WHERE word_id = $1 AND level = 5',
        [wordId]
      );
      
      if (level5Result.rows.length > 0) {
        const level5Quiz = level5Result.rows[0];
        let options = level5Quiz.options;
        
        if (typeof options === 'string') {
          options = JSON.parse(options);
        }
        
        // Update settings with real context data
        if (options.time_periods && Array.isArray(options.time_periods)) {
          // Create settings array matching the time_periods
          options.settings = options.time_periods.map((period, idx) => {
            if (idx < realSettings.length) {
              return realSettings[idx];
            }
            return `Setting ${period}`;
          });
          
          console.log(`  ✓ Updated Level 5 settings for ${word}`);
          
          // Update in database
          await pool.query(
            'UPDATE quiz_materials SET options = $1 WHERE id = $2',
            [JSON.stringify(options), level5Quiz.id]
          );
        }
      } else {
        console.log(`  ⚠️  No Level 5 quiz found for ${word}`);
      }
      
      // Update level 6 (story/beast mode) quiz
      const level6Result = await pool.query(
        'SELECT id, options FROM quiz_materials WHERE word_id = $1 AND level = 6',
        [wordId]
      );
      
      if (level6Result.rows.length > 0) {
        const level6Quiz = level6Result.rows[0];
        let options = level6Quiz.options;
        
        if (typeof options === 'string') {
          options = JSON.parse(options);
        }
        
        // Level 6 has both real and false settings
        if (options.time_periods && Array.isArray(options.time_periods)) {
          const realTimePeriods = story.map(turn => turn.century);
          const numReal = realTimePeriods.length;
          const numFake = options.time_periods.length - numReal;
          
          // Create real settings
          const realSettingsList = realSettings.slice(0, numReal);
          
          // Create fake settings (make them plausible but wrong)
          const fakeSettings = [];
          const fakeTemplates = [
            "Medieval European culture...",
            "Ancient Near Eastern traditions...",
            "Colonial American society...",
            "Victorian British empire...",
            "Post-war European reconstruction...",
            "Early modern scientific revolution...",
            "Renaissance Italian city-states...",
            "Enlightenment French salons..."
          ];
          
          for (let i = 0; i < numFake; i++) {
            if (i < fakeTemplates.length) {
              fakeSettings.push(fakeTemplates[i]);
            } else {
              fakeSettings.push(`False setting ${i + 1}`);
            }
          }
          
          // Combine real and fake settings
          options.settings = [...realSettingsList, ...fakeSettings];
          
          console.log(`  ✓ Updated Level 6 settings for ${word} (${numReal} real + ${numFake} fake)`);
          
          // Update in database
          await pool.query(
            'UPDATE quiz_materials SET options = $1 WHERE id = $2',
            [JSON.stringify(options), level6Quiz.id]
          );
        }
      } else {
        console.log(`  ⚠️  No Level 6 quiz found for ${word}`);
      }
    }
    
    console.log('\n✅ All quiz settings updated!');
    
  } catch (error) {
    console.error('❌ Error fixing quiz settings:', error);
  } finally {
    await pool.end();
  }
}

fixQuizSettings();

