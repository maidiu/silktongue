import { pool } from '../src/db/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Function to generate short setting label from long context
function generateShortSetting(context) {
  // Map common patterns to short labels
  const patterns = [
    [/theological|theology|scholastic|protestant/i, 'Theology'],
    [/scientific|physics|science|electromagnetic/i, 'Scientific Age'],
    [/mass media|advertising|commercial|capitalism/i, 'Mass Media Era'],
    [/digital|internet|network|technology/i, 'Digital Age'],
    [/carolingian|monastery/i, 'Carolingian Era'],
    [/medieval|alchemy|alchemist/i, 'Medieval Alchemy'],
    [/renaissance|printing|humanist/i, 'Renaissance'],
    [/rome|roman|latin/i, 'Rome'],
    [/greek|hellenic/i, 'Greece'],
    [/industrial|workshop|factory/i, 'Industrial Age'],
    [/enlightenment|salon|coffee house/i, 'Enlightenment'],
    [/victorian|19th.*britain/i, 'Victorian Era'],
    [/modern|contemporary|20th.*century/i, 'Modern Era'],
    [/ancient|classical/i, 'Ancient World'],
    [/medieval.*court/i, 'Medieval Courts'],
    [/natural history|naturalist/i, 'Natural History'],
    [/great.*houses|english.*houses/i, 'Great Houses'],
  ];

  for (const [pattern, label] of patterns) {
    if (pattern.test(context)) {
      return label;
    }
  }

  // If no pattern matches, try to extract a short meaningful phrase
  const words = context.split(/[\s,—]+/);
  if (words.length <= 3) {
    return context;
  }
  
  // Return first few capitalized words
  const capitalized = words.filter(w => /^[A-Z]/.test(w));
  if (capitalized.length >= 2) {
    return capitalized.slice(0, 2).join(' ');
  }
  
  // Fallback: return first 2-3 words
  return words.slice(0, Math.min(3, words.length)).join(' ');
}

async function fixAllLevel5Quizzes() {
  try {
    console.log('📖 Loading vocabulary entries from JSON...');
    
    // Load both week's vocab entries
    const week1Path = path.resolve(__dirname, '../../weekly_entries/2025.10.17.json');
    const week2Path = path.resolve(__dirname, '../../weekly_entries/2025.10.25.json');
    
    const week1Vocab = JSON.parse(fs.readFileSync(week1Path, 'utf8'));
    const week2Vocab = JSON.parse(fs.readFileSync(week2Path, 'utf8'));
    
    // Combine into a lookup map
    const vocabMap = {};
    [...week1Vocab, ...week2Vocab].forEach(entry => {
      vocabMap[entry.word.toLowerCase()] = entry;
    });
    
    console.log(`✓ Loaded ${Object.keys(vocabMap).length} vocabulary entries`);
    
    // Load both quiz files
    const quiz1Path = path.resolve(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json');
    const quiz2Path = path.resolve(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');
    
    const quiz1 = JSON.parse(fs.readFileSync(quiz1Path, 'utf8'));
    const quiz2 = JSON.parse(fs.readFileSync(quiz2Path, 'utf8'));
    
    console.log(`\n📝 Processing quiz files...`);
    
    let fixedCount = 0;
    
    // Function to fix a single quiz entry
    function fixLevel5Entry(entry, vocabEntry) {
      if (entry.level !== 5) return false;
      if (!vocabEntry || !vocabEntry.story) return false;
      
      const storyEvents = vocabEntry.story;
      
      // Check if this entry needs fixing
      const needsFix = entry.options.story_texts && 
                      entry.options.story_texts.some(text => text.includes('...'));
      
      if (!needsFix) {
        console.log(`  ✓ ${entry.word} Level 5 looks good`);
        return false;
      }
      
      console.log(`  🔧 Fixing ${entry.word} Level 5...`);
      
      // Extract full story texts and generate short settings
      const turns = storyEvents.map(e => e.story_text);
      const settings = storyEvents.map(e => generateShortSetting(e.context || ''));
      const timePeriods = storyEvents.map(e => {
        const century = e.century;
        // Handle both numeric (21) and string ('21st c.') formats
        if (century.toString().includes('c.') || century.toString().includes('CE')) {
          return century.toString();
        }
        return `${century}th c.`;
      });
      
      // Update the entry
      entry.options = {
        time_periods: timePeriods,
        settings: settings,
        turns: turns
      };
      
      // Update correct_answer to match new format
      entry.correct_answer = timePeriods.map((tp, i) => 
        `${tp} — ${settings[i]} → ${turns[i]}`
      );
      
      fixedCount++;
      return true;
    }
    
    // Process quiz 1
    console.log(`\n=== Processing 2025.10.17_quiz.json ===`);
    quiz1.forEach(entry => {
      const vocabEntry = vocabMap[entry.word.toLowerCase()];
      fixLevel5Entry(entry, vocabEntry);
    });
    
    // Process quiz 2
    console.log(`\n=== Processing 2025.10.25_quiz.json ===`);
    quiz2.forEach(entry => {
      const vocabEntry = vocabMap[entry.word.toLowerCase()];
      fixLevel5Entry(entry, vocabEntry);
    });
    
    console.log(`\n✅ Fixed ${fixedCount} Level 5 entries`);
    
    // Write back to files
    console.log(`\n💾 Writing corrected quiz files...`);
    fs.writeFileSync(quiz1Path, JSON.stringify(quiz1, null, 2));
    fs.writeFileSync(quiz2Path, JSON.stringify(quiz2, null, 2));
    console.log(`✓ Wrote ${quiz1Path}`);
    console.log(`✓ Wrote ${quiz2Path}`);
    
    // Now re-import to database
    console.log(`\n📥 Re-importing Level 5 quizzes to database...`);
    
    const level5Entries = [...quiz1, ...quiz2].filter(e => e.level === 5);
    
    for (const entry of level5Entries) {
      await pool.query(
        `UPDATE quiz_materials 
         SET options = $1, correct_answer = $2
         WHERE word_id = $3 AND level = 5`,
        [JSON.stringify(entry.options), JSON.stringify(entry.correct_answer), entry.word_id]
      );
    }
    
    console.log(`✅ Re-imported ${level5Entries.length} Level 5 quizzes to database`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixAllLevel5Quizzes();

