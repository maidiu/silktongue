import { pool } from '../src/db/index.js';

async function fixStoryQuestionIds() {
  try {
    console.log('Fixing story comprehension question word IDs...');
    
    // Map of words to their correct IDs
    const wordIdMap = {
      'impede': 1,
      'inherent': 13,
      'cohesive': 27,
      'scattershot': 42,
      'salient': 56,
      'perfunctory': 70,
      'omit': 83,
      'verisimilitude': 187
    };
    
    // Update each word's questions
    for (const [word, correctId] of Object.entries(wordIdMap)) {
      console.log(`\nUpdating ${word} from old word_id to ${correctId}...`);
      
      // First, get the current word_id for this word
      const { rows: currentRows } = await pool.query(`
        SELECT DISTINCT word_id FROM story_comprehension_questions 
        WHERE word_id IN (SELECT id FROM vocab_entries WHERE word = $1)
      `, [word]);
      
      if (currentRows.length > 0) {
        const oldId = currentRows[0].word_id;
        console.log(`  Current word_id: ${oldId}`);
        
        if (oldId !== correctId) {
          console.log(`  Updating to word_id ${correctId}...`);
          
          const updateResult = await pool.query(`
            UPDATE story_comprehension_questions
            SET word_id = $1
            WHERE word_id IN (SELECT id FROM vocab_entries WHERE word = $2)
          `, [correctId, word]);
          
          console.log(`  ✅ Updated ${updateResult.rowCount} questions`);
        } else {
          console.log(`  ✅ Already correct`);
        }
      } else {
        console.log(`  ⚠️ No questions found for ${word}`);
      }
    }
    
    console.log('\n✅ Done fixing word IDs');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

fixStoryQuestionIds();

