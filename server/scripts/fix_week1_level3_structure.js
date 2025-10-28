import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function fixWeek1Level3() {
  try {
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    
    const quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    
    console.log('🔄 Fixing Week 1 Level 3 structure to match Week 2...\n');
    
    let fixed = 0;
    
    for (const quiz of quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        // Check if options contains incorrect_answers and correct_answers
        if (quiz.options && quiz.options.incorrect_answers && quiz.options.correct_answers) {
          console.log(`  ✓ Fixing ${quiz.word}`);
          
          // Move them to top level
          quiz.incorrect_answers = quiz.options.incorrect_answers;
          quiz.correct_answers = quiz.options.correct_answers;
          
          // Remove options object entirely for level 3
          delete quiz.options;
          
          fixed++;
        }
      }
    }
    
    // Write back to file
    fs.writeFileSync(week1Path, JSON.stringify(quizzes, null, 2), 'utf-8');
    
    console.log(`\n✅ Fixed ${fixed} Level 3 quizzes in Week 1 to match Week 2 structure`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

fixWeek1Level3();

