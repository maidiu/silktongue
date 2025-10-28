import { pool } from '../src/db/index.js';

async function checkQuizLevels() {
  try {
    // Check a word from week 1
    console.log('\n====================');
    console.log('Week 1 word: impede');
    console.log('====================\n');
    
    const week1Res = await pool.query(
      `SELECT level, question_type, prompt FROM quiz_materials 
       WHERE word_id = (SELECT id FROM vocab_entries WHERE word = 'impede')
       ORDER BY level`
    );
    console.log(`Total questions: ${week1Res.rows.length}`);
    week1Res.rows.forEach(r => console.log(`  Level ${r.level}: ${r.question_type}`));
    
    // Check week 2 words
    console.log('\n====================');
    console.log('Week 2 words');
    console.log('====================\n');
    
    const week2Words = ['ubiquitous', 'plausible', 'elucidate'];
    for (const word of week2Words) {
      const res = await pool.query(
        `SELECT level, question_type, prompt FROM quiz_materials 
         WHERE word_id = (SELECT id FROM vocab_entries WHERE word = $1)
         ORDER BY level`,
        [word]
      );
      console.log(`\n${word} (${res.rows.length} questions):`);
      res.rows.forEach(r => console.log(`  Level ${r.level}: ${r.question_type}`));
    }
    
    // Check what question types exist in the database
    console.log('\n====================');
    console.log('All unique question types in database:');
    console.log('====================\n');
    const allTypes = await pool.query(
      `SELECT DISTINCT question_type, COUNT(*) as count 
       FROM quiz_materials 
       GROUP BY question_type 
       ORDER BY count DESC`
    );
    allTypes.rows.forEach(r => console.log(`  ${r.question_type}: ${r.count} questions`));
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

checkQuizLevels();

