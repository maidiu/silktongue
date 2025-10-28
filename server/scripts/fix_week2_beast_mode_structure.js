import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const quizFilePath = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');

// For each word, we need to:
// 1. Extract the 3 false settings from correct_answer
// 2. Extract short versions of the 3 false turns from red_herrings
// 3. Replace "False Setting 1/2/3" with real setting names
// 4. Add the 3 short false turns to the turns array

const fixData = {
  elucidate: {
    falseSettings: [
      'Carolingian Scriptoria',
      'Scholastic Philosophy',
      'Renaissance Humanism'
    ],
    shortFalseTurns: [
      'He was adopted by Carolingian scholars to illuminate sacred manuscripts—where *lūcidus* described the golden ink that made divine texts visible across the darkened scriptoria.',
      'He became central to scholastic debates where clarity was the highest virtue—where *ēlūcidāre* meant to untangle the knots of Aristotle\'s logic.',
      'He symbolized the Renaissance ideal of seeing through deception—where enlightenment meant recognizing truth beneath the layers of medieval darkness.'
    ]
  },
  plausible: {
    falseSettings: [
      'Scholastic Philosophy',
      'Chivalric Courts',
      'Renaissance Debate'
    ],
    shortFalseTurns: [
      'She was embraced by scholastic philosophers who believed truth required universal consensus—where *plaudibilis* became the measure of what all reasonable minds must accept.',
      'She became the standard of chivalric courts where public approval measured virtue—where the applause of nobles proved the knight\'s worth.',
      'She symbolized the Renaissance humanist\'s faith in public debate—where plausibility emerged from the free exchange of ideas.'
    ]
  },
  ubiquitous: {
    falseSettings: [
      'Carolingian Mysticism',
      'Medieval Alchemy',
      'Renaissance Printing'
    ],
    shortFalseTurns: [
      'He was adopted by Carolingian mystics to describe the omnipresent divine presence that infused all creation—where *ubīque* became the name for God\'s simultaneous existence.',
      'He became central to medieval theories of magic and alchemy—where ubiquity was the property of substances that could exist in all places simultaneously.',
      'He symbolized the humanist ideal of knowledge spreading universally—where the printing press made ideas ubiquitous across all European courts.'
    ]
  }
};

async function fixWeek2BeastMode() {
  console.log('🔄 Fixing Week 2 Beast Mode structure (elucidate, plausible, ubiquitous)...\n');
  
  const quizData = JSON.parse(fs.readFileSync(quizFilePath, 'utf8'));
  let changesMade = 0;
  
  const updatedQuizData = quizData.map(quiz => {
    if (quiz.level === 6 && fixData[quiz.word]) {
      console.log(`✓ Fixing ${quiz.word}:`);
      const fix = fixData[quiz.word];
      
      // Replace "False Setting 1/2/3" with real setting names
      const newSettings = quiz.options.settings.map(setting => {
        if (setting === 'False Setting 1') return fix.falseSettings[0];
        if (setting === 'False Setting 2') return fix.falseSettings[1];
        if (setting === 'False Setting 3') return fix.falseSettings[2];
        return setting;
      });
      
      // Add the 3 short false turns to the turns array
      const newTurns = [...quiz.options.turns, ...fix.shortFalseTurns];
      
      quiz.options.settings = newSettings;
      quiz.options.turns = newTurns;
      
      console.log(`  - Replaced "False Setting" placeholders with: ${fix.falseSettings.join(', ')}`);
      console.log(`  - Added ${fix.shortFalseTurns.length} short false turns to turns array`);
      console.log(`  - Total settings: ${newSettings.length}, Total turns: ${newTurns.length}\n`);
      
      changesMade++;
    }
    return quiz;
  });
  
  if (changesMade > 0) {
    fs.writeFileSync(quizFilePath, JSON.stringify(updatedQuizData, null, 2), 'utf8');
    console.log(`✅ Fixed ${changesMade} Beast Mode quizzes`);
  }
}

fixWeek2BeastMode();

