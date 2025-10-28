import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const quizFilePath = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');

async function fixPlaceholderSettings() {
  console.log('🔄 Fixing placeholder settings for elucidate, plausible, ubiquitous...\n');
  
  const quizData = JSON.parse(fs.readFileSync(quizFilePath, 'utf8'));
  let changesMade = 0;
  
  const wordsToFix = ['elucidate', 'plausible', 'ubiquitous'];
  
  const updatedQuizData = quizData.map(quiz => {
    if (quiz.level === 6 && wordsToFix.includes(quiz.word)) {
      // Extract real settings from correct_answer
      const realSettings = quiz.correct_answer.map(answer => {
        // Format: "1th c. — Real Setting → Story..."
        const match = answer.match(/^[^—]+—\s*([^→]+)\s*→/);
        return match ? match[1].trim() : null;
      }).filter(Boolean);
      
      if (realSettings.length > 0) {
        console.log(`✓ Fixing ${quiz.word}:`);
        console.log(`  Old settings: ${quiz.options.settings.slice(0, 4).join(', ')}`);
        console.log(`  New settings: ${realSettings.join(', ')}`);
        
        // Update the settings array
        quiz.options.settings = [
          ...realSettings,
          ...quiz.options.settings.filter(s => s.startsWith('False'))
        ];
        
        changesMade++;
      }
    }
    return quiz;
  });
  
  if (changesMade > 0) {
    fs.writeFileSync(quizFilePath, JSON.stringify(updatedQuizData, null, 2), 'utf8');
    console.log(`\n✅ Fixed ${changesMade} quizzes with placeholder settings`);
  } else {
    console.log('\n✅ No placeholder settings found');
  }
}

fixPlaceholderSettings();

