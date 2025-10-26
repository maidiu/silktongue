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
    for (const wordData of questionsData) {
      console.log(`\nProcessing word: ${wordData.word} (ID: ${wordData.word_id})`);
      
      for (const question of wordData.questions) {
        const insertQuery = `
          INSERT INTO story_comprehension_questions (
            word_id, century, question, options, correct_answer, explanation
          ) VALUES ($1, $2, $3, $4, $5, $6)
        `;
        
        const values = [
          wordData.word_id,
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
