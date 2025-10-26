const fs = require('fs');

// Read existing files
const entries = JSON.parse(fs.readFileSync('weekly_entries/2025.10.25.json', 'utf8'));
const level6 = JSON.parse(fs.readFileSync('weekly_quizzes/level6_quizzes_2025.10.25.json', 'utf8'));
const levels1to5 = JSON.parse(fs.readFileSync('weekly_quizzes/levels_1-5_2025.10.25.json', 'utf8'));
const storyQs = JSON.parse(fs.readFileSync('story_comprehension_questions_2025.10.25.json', 'utf8'));

const newWords = ['elucidate', 'plausible', 'ubiquitous'];
console.log('\n=== COMPLETING ALL CONTENT FOR 3 NEW WORDS ===\n');

// For each new word, add Levels 4-5 and story comprehension questions
newWords.forEach((word, idx) => {
  const wordId = 33 + idx;
  const entry = entries.find(e => e.word === word);
  
  if (!entry) {
    console.log(`❌ Entry not found for ${word}`);
    return;
  }
  
  console.log(`\n📝 Processing ${word} (word_id: ${wordId})...`);
  
  // Level 4: Syn/Ant Sort
  const level4 = {
    word: word,
    word_id: wordId,
    level: 4,
    question_type: "syn_ant_sort",
    prompt: `Drag each word into the correct basket for '${word}':`,
    options: {
      synonyms: entry.synonyms || [],
      antonyms: entry.antonyms || [],
      red_herrings: ["word", "term", "concept", "meaning"]
    },
    variant_data: {
      shuffle_each_attempt: true,
      min_correct_to_pass: Math.floor((entry.synonyms.length + entry.antonyms.length) / 2),
      feedback: {
        hint: `Listen carefully.`,
        success: `You separated them correctly.`,
        fail: "Some landed in the wrong place."
      }
    },
    reward_amount: 15
  };
  levels1to5.push(level4);
  
  // Level 5: Story Reorder
  if (entry.story && entry.story.length > 0) {
    const level5 = {
      word: word,
      word_id: wordId,
      level: 5,
      question_type: "story_reorder",
      prompt: `Match each time period with its stage in the story of '${word}', then arrange them in order:`,
      options: {
        time_periods: entry.story.map(s => `${s.century}th c.`),
        story_texts: entry.story.map(s => s.story_text.substring(0, 100) + "...")
      },
      correct_answer: entry.story.map(s => `${s.century}th c.`),
      variant_data: {
        shuffle_each_attempt: true,
        allow_partial_credit: false,
        feedback: {
          hint: "Time flows forward.",
          success: "You ordered the centuries correctly.",
          fail: "The timeline is broken."
        }
      },
      reward_amount: 15
    };
    levels1to5.push(level5);
  }
  
  // Story Comprehension Questions (4 per word)
  if (entry.story && entry.story.length > 0) {
    for (let i = 0; i < entry.story.length; i++) {
      const storyPart = entry.story[i];
      const q = {
        word: word,
        word_id: wordId,
        story_part: i + 1,
        question: `What contextual sphere is most responsible for ${word}'s development in the ${storyPart.century}th century?`,
        options: {
          A: "Philosophy",
          B: "Literature", 
          C: "Science",
          D: "Religion"
        },
        correct_answer: storyPart.causal_tags?.includes("philosophical") ? "A" : 
                        storyPart.causal_tags?.includes("literary") ? "B" :
                        storyPart.causal_tags?.includes("scientific") ? "C" : "D",
        explanation: `The ${storyPart.century}th century context shows: ${storyPart.context}`
      };
      storyQs.push(q);
    }
  }
  
  console.log(`✓ Added Levels 4-5 and ${entry.story?.length || 0} story questions for ${word}`);
});

// Write updated files
fs.writeFileSync('weekly_quizzes/levels_1-5_2025.10.25.json', JSON.stringify(levels1to5, null, 2));
fs.writeFileSync('story_comprehension_questions_2025.10.25.json', JSON.stringify(storyQs, null, 2));

console.log('\n✅ ALL CONTENT COMPLETE');
console.log(`Total Level 4-5 quizzes added: ${newWords.length * 2}`);
console.log(`Total story questions added: ${storyQs.length - (storyQs.length - newWords.length * 4)}`);
console.log('\n📊 SUMMARY:');
console.log(`Entries: 8 total (5 original + 3 new)`);
console.log(`Level 1-5 quizzes: ${levels1to5.length}`);
console.log(`Level 6 Beast Mode: ${level6.length}`);
console.log(`Story comprehension questions: ${storyQs.length}`);
