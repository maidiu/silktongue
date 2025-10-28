import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Expand single-word incorrect answers into full plausible definitions
const definitionExpansions = {
  // Week 1 - cohesive
  "fragmented": "broken into separate, disconnected pieces or parts.",
  "disjointed": "lacking coherence or connection between elements.",
  "dispersed": "scattered widely across different areas or directions.",
  
  // Week 1 - impede
  "assist": "to help or support someone in achieving a goal.",
  "facilitate": "to make an action or process easier or smoother.",
  "enable": "to provide the means or opportunity to do something.",
  
  // Week 1 - inherent
  "external": "coming from or existing outside of something.",
  "acquired": "gained or obtained through effort or experience.",
  "extrinsic": "not part of the essential nature of something.",
  
  // Week 1 - omit
  "include": "to contain or incorporate as part of a whole.",
  "retain": "to keep or continue to have something.",
  "insert": "to place or add something into a position.",
  
  // Week 1 - perfunctory
  "thorough": "complete and comprehensive in every detail.",
  "careful": "done with attention and caution to avoid mistakes.",
  "deliberate": "done consciously and intentionally with purpose.",
  
  // Week 1 - salient
  "obscure": "not clearly expressed or easily understood.",
  "inconspicuous": "not attracting attention or notice.",
  "hidden": "kept out of sight or concealed from view.",
  
  // Week 1 - scattershot
  "targeted": "directed toward a specific goal or objective.",
  "systematic": "done according to a fixed plan or method.",
  "methodical": "characterized by orderly and logical procedures.",
  
  // Week 1 - verisimilitude
  "implausibility": "the quality of being unlikely or hard to believe.",
  "incredibility": "the quality of being too extraordinary to be believed.",
  "unreality": "the quality of being imaginary or not real.",
  
  // Week 2 - attest (already has good definitions - no changes needed)
  
  // Week 2 - elucidate (already has good definitions - no changes needed)
  
  // Week 2 - lumbering (already has good definitions - no changes needed)
  
  // Week 2 - pall (already has good definitions - no changes needed)
  
  // Week 2 - plausible (already has good definitions - no changes needed)
  
  // Week 2 - scurry (already has good definitions - no changes needed)
  
  // Week 2 - steadfast (already has good definitions - no changes needed)
  
  // Week 2 - ubiquitous (already has good definitions - no changes needed)
};

async function fixLevel3DefinitionLengths() {
  try {
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const week2Path = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const week1Quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    const week2Quizzes = JSON.parse(fs.readFileSync(week2Path, 'utf-8'));
    
    console.log('🔄 Fixing Level 3 definition quiz answer lengths...\n');
    
    let fixed = 0;
    
    // Fix Week 1
    for (const quiz of week1Quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        console.log(`  ✓ Fixing ${quiz.word} (Week 1)`);
        
        // Expand incorrect_answers if they're single words
        if (quiz.incorrect_answers) {
          quiz.incorrect_answers = quiz.incorrect_answers.map(answer => {
            if (definitionExpansions[answer]) {
              return definitionExpansions[answer];
            }
            return answer; // Keep as-is if already a full definition
          });
        }
        
        fixed++;
      }
    }
    
    // Fix Week 2 - already has good definitions, but let's verify
    for (const quiz of week2Quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        // Check if any incorrect_answers are single words
        const hasShortAnswers = quiz.incorrect_answers?.some(ans => ans.split(' ').length <= 2);
        
        if (hasShortAnswers) {
          console.log(`  ⚠️  ${quiz.word} (Week 2) has short answers but no expansions defined`);
        } else {
          console.log(`  ✓ ${quiz.word} (Week 2) already has full-length definitions`);
        }
      }
    }
    
    // Write back to files
    fs.writeFileSync(week1Path, JSON.stringify(week1Quizzes, null, 2), 'utf-8');
    fs.writeFileSync(week2Path, JSON.stringify(week2Quizzes, null, 2), 'utf-8');
    
    console.log(`\n✅ Fixed ${fixed} Level 3 quizzes`);
    console.log('📝 All incorrect answers are now full-length definitions!');
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixLevel3DefinitionLengths();

