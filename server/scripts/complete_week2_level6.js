import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function completeWeek2Level6() {
  try {
    console.log('Creating Level 6 Beast Mode quizzes for week 2 words...\n');
    
    // Read the weekly entries to get complete story data
    const weeklyEntries = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../../weekly_entries/2025.10.25.json'), 'utf8')
    );
    
    const level6File = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../../weekly_quizzes/level6_quizzes_2025.10.25.json'), 'utf8')
    );
    
    // Process words that need fixing
    const wordsToFix = ['elucidate', 'plausible', 'ubiquitous'];
    
    for (const word of wordsToFix) {
      const entry = weeklyEntries.find(e => e.word === word);
      if (!entry || !entry.story) {
        console.log(`⚠ Could not find story for: ${word}`);
        continue;
      }
      
      // Get the actual word_id
      const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [word]);
      if (wordRes.rows.length === 0) {
        console.log(`⚠ Word ${word} not found in database`);
        continue;
      }
      const word_id = wordRes.rows[0].id;
      
      console.log(`Processing: ${word} (ID: ${word_id})`);
      
      // Create proper options from the story
      const storyParts = entry.story;
      const realCenturies = storyParts.map(s => {
        const century = s.century.includes('st') ? s.century : `${s.century}th c.`;
        return century;
      });
      const realSettings = storyParts.map(s => s.context);
      const realStories = storyParts.map(s => s.story_text);
      
      // Add false options
      const falseCenturies = ['8th c.', '12th c.', '15th c.'];
      const falseSettings = [
        'False Historical Period',
        'Another False Era', 
        'Third Fictional Century'
      ];
      const falseStories = [
        `He was forgotten entirely in this period and had no development.`,
        `He gained magical properties during this time that were later lost.`,
        `He was completely rejected by scholars who found no use for him.`
      ];
      
      const allCenturies = [...realCenturies, ...falseCenturies];
      const allSettings = [...realSettings, ...falseSettings];
      const allStories = [...realStories, ...falseStories];
      
      // Build correct answer
      const correctAnswer = realCenturies.map((century, idx) => 
        `${century} — ${realSettings[idx]} → ${realStories[idx]}`
      );
      
      // Create the quiz object
      const quiz = {
        word_id,
        level: 6,
        question_type: 'story',
        prompt: `Rebuild the full story of '${word}'—beware the three false centuries. Conquer the beast for double silk.`,
        options: {
          time_periods: allCenturies,
          settings: allSettings,
          turns: allStories,
          red_herrings: falseStories
        },
        correct_answer: correctAnswer,
        variant_data: {
          shuffle_each_attempt: true,
          allow_partial_credit: false,
          hard_mode_penalty: {
            health_loss_on_fail: 2,
            reward_multiplier_on_success: 2
          },
          feedback: {
            hint: "Some centuries whisper lies.",
            success: "You have slain the beast of confusion. Double silk earned.",
            fail: "The beast devoured your certainty. Try again."
          }
        },
        difficulty: 'hard',
        reward_amount: 50
      };
      
      // Delete any existing level 6 quiz for this word first
      await pool.query('DELETE FROM quiz_materials WHERE word_id = $1 AND level = 6', [word_id]);
      
      // Insert into database
      const insertQuery = `
        INSERT INTO quiz_materials 
        (word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `;
      
      const values = [
        word_id,
        quiz.level,
        quiz.question_type,
        quiz.prompt,
        JSON.stringify(quiz.options),
        JSON.stringify(quiz.correct_answer),
        JSON.stringify(quiz.variant_data),
        quiz.reward_amount
      ];
      
      await pool.query(insertQuery, values);
      console.log(`  ✓ Created complete Level 6 quiz for ${word}\n`);
    }
    
    console.log('✅ All Level 6 Beast Mode quizzes completed!');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

completeWeek2Level6();

