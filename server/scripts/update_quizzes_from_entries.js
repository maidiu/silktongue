// Update quiz and story files to match weekly_entries
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const week1_entries = JSON.parse(fs.readFileSync(path.join(__dirname, '../../weekly_entries/2025.10.17.json'), 'utf8'));
const week1_storyQs = JSON.parse(fs.readFileSync(path.join(__dirname, '../../story_comprehension_questions.json'), 'utf8'));

console.log('Updating story comprehension questions to match entries...\n');

// Helper to create comprehension question from a story event
function createQuestion(event, word) {
  // Extract century, context, and story text
  const { century, story_text, context, sibling_words } = event;
  
  // Generate question options based on the story text
  // This is a simplified approach - in reality you'd want more sophisticated question generation
  const baseQuestion = `How did ${word} develop in the ${century}th century?`;
  
  const options = [
    story_text.substring(0, 80) + '...', // Correct answer
    'The word gained magical properties and supernatural meaning.',
    'The word was completely abandoned and forgotten.',
    'The word underwent no significant changes in this period.'
  ];
  
  return {
    century,
    story_text,
    context,
    sibling_words,
    question: baseQuestion,
    options,
    correct_answer: options[0],
    explanation: `The text describes how ${word} evolved during this period.`
  };
}

// Process each word from week 1
week1_entries.forEach(entry => {
  console.log(`Processing: ${entry.word}`);
  
  const existingQ = week1_storyQs.find(s => s.word === entry.word);
  
  // Check if timeline matches
  const entryCenturies = entry.story.map(s => s.century).join(', ');
  const qCenturies = existingQ?.questions?.map(q => q.century).join(', ') || 'none';
  
  if (entryCenturies !== qCenturies) {
    console.log(`  Timeline mismatch: Entry(${entryCenturies}) vs Q(${qCenturies})`);
    
    if (existingQ) {
      // Update existing entry
      existingQ.questions = entry.story.map(event => createQuestion(event, entry.word));
      console.log(`  Updated questions for ${entry.word}`);
    } else {
      // Create new entry
      week1_storyQs.push({
        word_id: week1_storyQs.length + 1,
        word: entry.word,
        questions: entry.story.map(event => createQuestion(event, entry.word))
      });
      console.log(`  Created new questions for ${entry.word}`);
    }
  }
});

console.log('\nSaving updated story_comprehension_questions.json...');
fs.writeFileSync(
  path.join(__dirname, '../../story_comprehension_questions.json'),
  JSON.stringify(week1_storyQs, null, 2)
);

console.log('Done!');

