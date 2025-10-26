const fs = require('fs');
const entries = JSON.parse(fs.readFileSync('weekly_entries/2025.10.25.json', 'utf8'));
const level6Template = JSON.parse(fs.readFileSync('weekly_quizzes/level6_quizzes_2025.10.25.json', 'utf8'));
const levels1to5Template = JSON.parse(fs.readFileSync('weekly_quizzes/levels_1-5_2025.10.25.json', 'utf8'));
const storyQsTemplate = JSON.parse(fs.readFileSync('story_comprehension_questions_2025.10.25.json', 'utf8'));

const newWords = ['elucidate', 'plausible', 'ubiquitous'];
console.log('Will now add quizzes and questions for:', newWords.join(', '));

// This will append to existing files following the same patterns
