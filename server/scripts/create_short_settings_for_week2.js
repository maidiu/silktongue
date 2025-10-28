import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const quizFilePath = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');

// Mapping of long settings to short labels based on the correct_answer format
const settingsMap = {
  // elucidate
  'Latin usage emphasizing clarity and transparency as intrinsic qualities of light and perception.': 'Ancient Rome',
  'Renaissance humanism and scholarly tradition using classical Latin for precise intellectual operations.': 'Renaissance Humanism',
  'Enlightenment philosophy and scientific method prioritizing clarity, reason, and systematic explanation.': 'Enlightenment',
  'Modern educational and analytical discourse where explanation has become routine institutional practice.': 'Modern Education',
  
  // plausible
  'Roman rhetorical and theatrical culture where audience approval measured persuasive success.': 'Rome',
  'Enlightenment philosophy and probability theory distinguishing appearance from certainty.': 'Enlightenment',
  'Victorian social codes emphasizing proper appearance and public respectability.': 'Victorian England',
  'Modern discourse where persuasive presentation competes with factual verification.': 'Modern Media',
  
  // ubiquitous
  'Scholastic and Protestant theology concerning divine omnipresence.': 'Theological Scholasticism',
  'Nineteenth-century physics and metaphysics theorizing universal forces and fields.': 'Scientific Age',
  'Mass media, advertising, and global capitalism distributing products and images universally.': 'Mass Media Era',
  'Digital technology and internet culture creating universal connectivity and constant presence.': 'Digital Age'
};

async function createShortSettings() {
  console.log('🔄 Creating short settings labels for week 2 quizzes...\n');
  
  const quizData = JSON.parse(fs.readFileSync(quizFilePath, 'utf8'));
  let changesMade = 0;
  
  const updatedQuizData = quizData.map(quiz => {
    if (quiz.level === 6 && ['elucidate', 'plausible', 'ubiquitous'].includes(quiz.word)) {
      console.log(`✓ Fixing ${quiz.word}:`);
      console.log(`  Old settings:`, quiz.options.settings.slice(0, 2));
      
      const newSettings = quiz.options.settings.map(setting => {
        if (settingsMap[setting]) {
          return settingsMap[setting];
        }
        return setting; // Keep "False Setting" as-is
      });
      
      quiz.options.settings = newSettings;
      console.log(`  New settings:`, newSettings.slice(0, 4));
      changesMade++;
    }
    return quiz;
  });
  
  if (changesMade > 0) {
    fs.writeFileSync(quizFilePath, JSON.stringify(updatedQuizData, null, 2), 'utf8');
    console.log(`\n✅ Created short settings for ${changesMade} quizzes`);
  }
}

createShortSettings();

