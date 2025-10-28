// Compare story timelines across files
import fs from 'fs';

const entries = JSON.parse(fs.readFileSync('weekly_entries/2025.10.17.json', 'utf8'));
const storyQs = JSON.parse(fs.readFileSync('story_comprehension_questions.json', 'utf8'));
const level5 = JSON.parse(fs.readFileSync('weekly_quizzes/level5_quizzes_fixed.json', 'utf8'));
const level6 = JSON.parse(fs.readFileSync('weekly_quizzes/level6_quizzes.json', 'utf8'));

const words = ['impede', 'inherent', 'cohesive', 'scattershot', 'salient', 'perfunctory', 'omit', 'verisimilitude'];

words.forEach(word => {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`WORD: ${word.toUpperCase()}`);
  console.log('='.repeat(60));
  
  const entry = entries.find(e => e.word === word);
  if (!entry) {
    console.log('NOT IN WEEKLY_ENTRIES');
    return;
  }
  
  const entryCenturies = entry.story.map(s => s.century).join(', ');
  console.log(`\nEntry timeline:        ${entryCenturies}`);
  
  const storyQ = storyQs.find(s => s.word === word);
  if (storyQ) {
    const qCenturies = storyQ.questions.map(q => q.century).join(', ');
    console.log(`Story Q timeline:       ${qCenturies}`);
    if (entryCenturies !== qCenturies) {
      console.log(`⚠️  MISMATCH!`);
    }
  } else {
    console.log('Story Q: NOT FOUND');
  }
  
  const q5 = level5.find(q => q.word === word);
  if (q5) {
    const times = q5.options.time_periods.join(', ');
    console.log(`Level 5 timeline:       ${times}`);
  } else {
    console.log('Level 5: NOT FOUND');
  }
  
  const q6 = level6.find(q => q.word === word);
  if (q6) {
    const times = q6.options.time_periods.filter((t, i, arr) => {
      // Only include real centuries, not red herrings
      const redHerringIndices = [4, 5, 6]; // indices of red herrings in typical level6
      return !redHerringIndices.includes(i);
    }).join(', ');
    console.log(`Level 6 timeline:       ${times}`);
  } else {
    console.log('Level 6: NOT FOUND');
  }
});

console.log('\n' + '='.repeat(60));
console.log('MISSING QUIZZES');
console.log('='.repeat(60));

const level6Words = level6.map(q => q.word);
const level5Words = level5.map(q => q.word);
const storyQWords = storyQs.map(s => s.word);

words.forEach(word => {
  const missing = [];
  if (!level6Words.includes(word)) missing.push('Level 6');
  if (!level5Words.includes(word)) missing.push('Level 5');
  if (!storyQWords.includes(word)) missing.push('Story Q');
  
  if (missing.length > 0) {
    console.log(`${word}: Missing from ${missing.join(', ')}`);
  }
});

