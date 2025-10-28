import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function createLevel6Quizzes() {
  try {
    // Read the weekly entries to get complete story data
    const weeklyEntries = JSON.parse(fs.readFileSync(path.join(__dirname, '../../weekly_entries/2025.10.25.json'), 'utf8'));
    const words = ['elucidate', 'plausible', 'ubiquitous'];
    
    for (const word of words) {
      const entry = weeklyEntries.find(e => e.word === word);
      if (!entry || !entry.story) {
        console.log(`⚠ Could not find complete story for: ${word}`);
        continue;
      }
      
      // Get the actual word_id
      const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [word]);
      if (wordRes.rows.length === 0) {
        console.log(`⚠ Word ${word} not found in database`);
        continue;
      }
      const word_id = wordRes.rows[0].id;
      
      console.log(`\nCreating Level 6 quiz for: ${word} (ID: ${word_id})`);
      
      // Extract the 4 story parts
      const storyParts = entry.story;
      
      // Create the level 6 Beast Mode quiz
      const quiz = {
        word_id: word_id,
        level: 6,
        question_type: 'story',
        prompt: `Rebuild the full story of '${word}'—beware the three false centuries. Conquer the beast for double silk.`,
        options: {
          time_periods: [],
          settings: [],
          turns: [],
          red_herrings: []
        },
        correct_answer: [],
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
      
      // Add the four real time periods and their stories
      const realPeriods = [];
      for (const part of storyParts) {
        realPeriods.push({
          century: `${part.century}th c.`,
          story: part.story_text,
          context: part.context
        });
        
        // Add to correct answer
        quiz.correct_answer.push(
          `${part.century}th c. — ${part.context} → ${part.story_text}`
        );
        
        quiz.options.turns.push(part.story_text);
      }
      
      // Add real time periods to options
      quiz.options.time_periods = realPeriods.map(rp => `${rp.century}`);
      quiz.options.settings = storyParts.map(s => s.context);
      
      // Add 3 false centuries and stories (red herrings)
      const falseCenturies = ['8th c.', '12th c.', '15th c.'];
      const falseContexts = [
        'Carolingian Empire',
        'Medieval Courts', 
        'Renaissance Humanism'
      ];
      
      quiz.options.time_periods.push(...falseCenturies);
      
      for (let i = 0; i < 3; i++) {
        quiz.options.red_herrings.push(
          `False story about ${word} in ${falseCenturies[i]}, set in ${falseContexts[i]}, where ${word} took on properties that never actually occurred.`
        );
      }
      
      // Insert into database
      const values = [
        word_id,
        6,
        quiz.question_type,
        quiz.prompt,
        JSON.stringify(quiz.options),
        JSON.stringify(quiz.correct_answer),
        JSON.stringify(quiz.variant_data),
        quiz.reward_amount || 50
      ];
      
      const query = `
        INSERT INTO quiz_materials 
        (word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (word_id, level, question_type) 
        DO UPDATE SET
          prompt = EXCLUDED.prompt,
          options = EXCLUDED.options,
          correct_answer = EXCLUDED.correct_answer,
          variant_data = EXCLUDED.variant_data,
          reward_amount = EXCLUDED.reward_amount
      `;
      
      await pool.query(query, values);
      console.log(`✓ Created Level 6 quiz for ${word}`);
    }
    
    console.log('\n✅ Complete!');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

createLevel6Quizzes();

