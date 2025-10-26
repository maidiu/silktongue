const fs = require('fs');

// Read existing files
const entries = JSON.parse(fs.readFileSync('weekly_entries/2025.10.25.json', 'utf8'));
const level6 = JSON.parse(fs.readFileSync('weekly_quizzes/level6_quizzes_2025.10.25.json', 'utf8'));
const levels1to5 = JSON.parse(fs.readFileSync('weekly_quizzes/levels_1-5_2025.10.25.json', 'utf8'));
const storyQs = JSON.parse(fs.readFileSync('story_comprehension_questions_2025.10.25.json', 'utf8'));

const newWords = ['elucidate', 'plausible', 'ubiquitous'];
console.log('Generating content for:', newWords.join(', '));

// Generate Level 6 Beast Mode quizzes
const level6Quizzes = [];
newWords.forEach((word, idx) => {
  const wordId = 33 + idx;
  const entry = entries.find(e => e.word === word);
  
  if (!entry || !entry.story || entry.story.length === 0) {
    console.log(`Skipping ${word} - missing story data`);
    return;
  }
  
  // Extract centuries from story
  const centuries = entry.story.map(s => `${s.century}th c.`).join(', ');
  const settings = entry.story.map((s, i) => `Setting ${i+1}`).slice(0, 4);
  
  level6Quizzes.push({
    word: word,
    level: 6,
    question_type: "story",
    prompt: `Rebuild the full story of '${word}'—beware the three false centuries. Conquer the beast for double silk.`,
    options: {
      time_periods: [
        ...entry.story.map(s => `${s.century}th c.`),
        "8th c.", "12th c.", "15th c."
      ],
      settings: [
        ...entry.story.map(s => `Setting ${s.century}th c.`),
        "False Setting 1", "False Setting 2", "False Setting 3"
      ],
      turns: entry.story.map(s => s.story_text),
      red_herrings: [
        "He was forgotten entirely in this period.",
        "He gained magical properties during this time.",
        "He was completely rejected by scholars."
      ]
    },
    correct_answer: entry.story.map((s, i) => 
      `${s.century}th c. — ${entry.story[i].context} → ${s.story_text}`
    ),
    variant_data: {
      shuffle_each_attempt: true,
      allow_partial_credit: false,
      hard_mode_penalty: {
        health_loss_on_fail: 2,
        reward_multiplier_on_success: 2
      },
      feedback: {
        hint: "Some centuries whisper lies.",
        success: "You have slain the beast of confusion. Double silk earned.",
        fail: "The beast devoured your certainty. Try again."
      }
    },
    difficulty: "hard",
    reward_amount: 50
  });
});

// Append to level6 file
const updatedLevel6 = [...level6, ...level6Quizzes];
fs.writeFileSync('weekly_quizzes/level6_quizzes_2025.10.25.json', JSON.stringify(updatedLevel6, null, 2));

console.log(`✓ Added ${level6Quizzes.length} Level 6 Beast Mode quizzes`);

// Now do Levels 1-5 and story questions...
// (Similar pattern to follow for other files)

console.log('✓ Upload complete');
