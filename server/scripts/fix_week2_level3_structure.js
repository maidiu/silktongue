import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function fixWeek2Level3() {
  try {
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    console.log('🔄 Fixing Week 2 Level 3 structure...\n');
    
    let fixed = 0;
    
    for (const quiz of quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        // Check if incorrect_answers and correct_answers are at top level
        if (quiz.incorrect_answers && quiz.correct_answers) {
          console.log(`  ✓ Fixing ${quiz.word || 'word_id ' + quiz.word_id}`);
          
          // Move them into options
          quiz.options = {
            incorrect_answers: quiz.incorrect_answers,
            correct_answers: quiz.correct_answers
          };
          
          // Remove from top level
          delete quiz.incorrect_answers;
          delete quiz.correct_answers;
          
          fixed++;
        }
      }
    }
    
    // Write back to file
    fs.writeFileSync(week2Path, JSON.stringify(quizzes, null, 2), 'utf-8');
    
    console.log(`\n✅ Fixed ${fixed} Level 3 quizzes in Week 2`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

fixWeek2Level3();

