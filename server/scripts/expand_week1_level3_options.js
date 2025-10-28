import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Expand to 8 incorrect + 4 correct for each word
const expandedDefinitions = {
  cohesive: {
    incorrect_answers: [
      "broken into separate, disconnected pieces or parts.",
      "lacking coherence or connection between elements.",
      "scattered widely across different areas or directions.",
      "having parts that work against each other.",
      "disorganized and without structure or unity.",
      "separated by gaps or divisions that prevent harmony.",
      "composed of unrelated or conflicting components.",
      "characterized by internal division and discord."
    ],
    correct_answers: [
      "forming a united whole; characterized by cohesion.",
      "having all parts or elements connected together.",
      "unified and logically consistent throughout.",
      "sticking together as a single integrated unit."
    ]
  },
  impede: {
    incorrect_answers: [
      "to help or support someone in achieving a goal.",
      "to make an action or process easier or smoother.",
      "to provide the means or opportunity to do something.",
      "to accelerate progress or speed up movement.",
      "to remove obstacles from someone's path.",
      "to encourage and assist forward momentum.",
      "to clear the way for advancement or growth.",
      "to enable or empower someone to proceed."
    ],
    correct_answers: [
      "to slow or block progress, movement, or development.",
      "to hinder or obstruct forward motion.",
      "to create obstacles that delay advancement.",
      "to interfere with the normal course of action."
    ]
  },
  inherent: {
    incorrect_answers: [
      "coming from or existing outside of something.",
      "gained or obtained through effort or experience.",
      "not part of the essential nature of something.",
      "added or attached from an external source.",
      "temporary and removable without changing essence.",
      "acquired through learning rather than existing naturally.",
      "imposed from without rather than existing within.",
      "conditional and dependent on external factors."
    ],
    correct_answers: [
      "existing as a permanent, essential attribute of something.",
      "intrinsic and inseparable from the nature of something.",
      "built-in as a fundamental characteristic.",
      "naturally present as part of the basic structure."
    ]
  },
  omit: {
    incorrect_answers: [
      "to contain or incorporate as part of a whole.",
      "to keep or continue to have something.",
      "to place or add something into a position.",
      "to include all relevant information or elements.",
      "to ensure nothing is left out or missing.",
      "to add or append additional material.",
      "to retain all parts without exclusion.",
      "to insert or introduce new components."
    ],
    correct_answers: [
      "to leave out or exclude intentionally or accidentally.",
      "to fail to include or mention something.",
      "to skip or pass over without including.",
      "to neglect to do or include something required."
    ]
  },
  perfunctory: {
    incorrect_answers: [
      "complete and comprehensive in every detail.",
      "done with attention and caution to avoid mistakes.",
      "done consciously and intentionally with purpose.",
      "carried out with genuine enthusiasm and care.",
      "performed with meticulous attention to quality.",
      "executed with dedication and thoroughness.",
      "accomplished with sincere effort and interest.",
      "completed with careful consideration of all aspects."
    ],
    correct_answers: [
      "done quickly and without real interest or effort.",
      "carried out with minimum attention or care.",
      "performed routinely without genuine involvement.",
      "executed mechanically without thought or feeling."
    ]
  },
  salient: {
    incorrect_answers: [
      "not clearly expressed or easily understood.",
      "not attracting attention or notice.",
      "kept out of sight or concealed from view.",
      "unimportant and easily overlooked.",
      "subtle and requiring effort to perceive.",
      "hidden beneath the surface or obscured.",
      "insignificant and barely worth mentioning.",
      "unremarkable and lacking distinctive features."
    ],
    correct_answers: [
      "most noticeable or important; prominent or striking.",
      "standing out clearly and demanding attention.",
      "conspicuous and immediately apparent.",
      "remarkably prominent or significant."
    ]
  },
  scattershot: {
    incorrect_answers: [
      "directed toward a specific goal or objective.",
      "done according to a fixed plan or method.",
      "characterized by orderly and logical procedures.",
      "focused and precisely targeted at one thing.",
      "systematic and well-organized in approach.",
      "carefully aimed with deliberate precision.",
      "structured according to a coherent strategy.",
      "concentrated on a single, well-defined purpose."
    ],
    correct_answers: [
      "lacking focus or organization; random or haphazard.",
      "covering many things without clear direction.",
      "indiscriminate and unfocused in approach.",
      "spread broadly without specific targeting."
    ]
  },
  verisimilitude: {
    incorrect_answers: [
      "the quality of being unlikely or hard to believe.",
      "the quality of being too extraordinary to be believed.",
      "the quality of being imaginary or not real.",
      "the appearance of obvious falsehood or deception.",
      "the characteristic of being implausible or absurd.",
      "the quality of seeming fake or artificial.",
      "the state of being transparently false.",
      "the property of lacking credibility or realism."
    ],
    correct_answers: [
      "the appearance or quality of being true or real.",
      "the quality of seeming to be true or believable.",
      "the lifelike quality that makes something credible.",
      "the realistic appearance that suggests authenticity."
    ]
  }
};

async function expandWeek1Level3Options() {
  try {
    const week1Path = path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const quizzes = JSON.parse(fs.readFileSync(week1Path, 'utf-8'));
    
    console.log('🔄 Expanding Week 1 Level 3 quizzes to 8 incorrect + 4 correct answers...\n');
    
    let expanded = 0;
    
    for (const quiz of quizzes) {
      if (quiz.level === 3 && quiz.question_type === 'definition') {
        const word = quiz.word;
        
        if (expandedDefinitions[word]) {
          console.log(`  ✓ Expanding ${word}: 3→8 incorrect, 1→4 correct`);
          
          quiz.incorrect_answers = expandedDefinitions[word].incorrect_answers;
          quiz.correct_answers = expandedDefinitions[word].correct_answers;
          
          // Update the single correct_answer field to match the first correct answer
          quiz.correct_answer = expandedDefinitions[word].correct_answers[0];
          
          expanded++;
        } else {
          console.log(`  ⚠️  No expansion defined for ${word}`);
        }
      }
    }
    
    // Write back to file
    fs.writeFileSync(week1Path, JSON.stringify(quizzes, null, 2), 'utf-8');
    
    console.log(`\n✅ Expanded ${expanded} Level 3 quizzes in Week 1`);
    console.log('📝 All quizzes now have 8 incorrect + 4 correct answers!');
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

expandWeek1Level3Options();

