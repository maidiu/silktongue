import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function importStoryQuestions() {
  try {
    console.log('Starting import of story comprehension questions...');
    
    // Read the JSON file
    const questionsPath = path.join(__dirname, '../../story_comprehension_questions.json');
    const questionsData = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
    
    console.log(`Found ${questionsData.length} words with story questions`);
    
    // Clear existing questions
    await pool.query('DELETE FROM story_comprehension_questions');
    console.log('Cleared existing story comprehension questions');
    
    let totalQuestions = 0;
    
    // Import questions for each word
    for (const item of questionsData) {
      if (!item.word || !item.questions) continue;
      
      // Look up the actual word_id from the database
      const wordLookup = await pool.query(
        'SELECT id FROM vocab_entries WHERE word = $1',
        [item.word]
      );
      
      if (wordLookup.rows.length === 0) {
        console.log(`⚠ Skipping ${item.word}: not found in database`);
        continue;
      }
      
      const actualWordId = wordLookup.rows[0].id;
      console.log(`\nProcessing word: ${item.word} (ID: ${actualWordId})`);
      
      for (const question of item.questions) {
        const insertQuery = `
          INSERT INTO story_comprehension_questions (
            word_id, century, question, options, correct_answer, explanation
          ) VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT (word_id, century) DO UPDATE SET
            question = EXCLUDED.question,
            options = EXCLUDED.options,
            correct_answer = EXCLUDED.correct_answer,
            explanation = EXCLUDED.explanation
        `;
        
        const values = [
          actualWordId,
          question.century,
          question.question,
          JSON.stringify(question.options),
          question.correct_answer,
          question.explanation
        ];
        
        await pool.query(insertQuery, values);
        totalQuestions++;
        console.log(`  ✓ Added question for ${question.century} century`);
      }
    }
    
    console.log(`\n✅ Successfully imported ${totalQuestions} story comprehension questions`);
    
    // Verify the import
    const verifyQuery = `
      SELECT 
        COUNT(*) as total_questions,
        COUNT(DISTINCT word_id) as words_with_questions
      FROM story_comprehension_questions
    `;
    
    const { rows } = await pool.query(verifyQuery);
    console.log(`\nVerification:`);
    console.log(`- Total questions: ${rows[0].total_questions}`);
    console.log(`- Words with questions: ${rows[0].words_with_questions}`);
    
  } catch (error) {
    console.error('Error importing story questions:', error);
  } finally {
    await pool.end();
  }
}

importStoryQuestions();

