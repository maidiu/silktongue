import { pool } from '../src/db/index.js';

async function checkCounts() {
  const result = await pool.query(`
    SELECT v.word, COUNT(q.id) as quiz_count, STRING_AGG(DISTINCT q.level::text, ', ' ORDER BY q.level::text) as levels
    FROM quiz_materials q
    JOIN vocab_entries v ON q.word_id = v.id
    GROUP BY v.word
    ORDER BY v.word
  `);

  const week1 = ['impede', 'inherent', 'cohesive', 'scattershot', 'salient', 'perfunctory', 'omit', 'verisimilitude'];
  const week2 = ['attest', 'pall', 'lumbering', 'scurry', 'steadfast', 'elucidate', 'plausible', 'ubiquitous'];
  
  console.log('📋 WORD BREAKDOWN:\n');
  
  console.log('Week 1 Words (8):');
  let foundWeek1 = 0;
  week1.forEach(word => {
    const row = result.rows.find(r => r.word === word);
    if (row) {
      console.log(`   ✓ ${word}: ${row.quiz_count} quizzes, Levels ${row.levels}`);
      foundWeek1++;
    }
  });
  
  console.log('\nWeek 2 Words (8):');
  let foundWeek2 = 0;
  week2.forEach(word => {
    const row = result.rows.find(r => r.word === word);
    if (row) {
      console.log(`   ✓ ${word}: ${row.quiz_count} quizzes, Levels ${row.levels}`);
      foundWeek2++;
    }
  });
  
  // Find extra words
  const allWords = result.rows.map(r => r.word);
  const extraWords = allWords.filter(w => !week1.includes(w) && !week2.includes(w));
  
  console.log('\nExtra Words (used as options in quizzes):');
  extraWords.forEach(word => {
    const row = result.rows.find(r => r.word === word);
    console.log(`   ${word}: ${row.quiz_count} quizzes, Levels ${row.levels}`);
  });
  
  console.log('\n✅ Summary:');
  console.log(`   Week 1 words: ${foundWeek1}/8`);
  console.log(`   Week 2 words: ${foundWeek2}/8`);
  console.log(`   Extra words (synonyms/antonyms): ${extraWords.length}`);
  console.log(`   Total unique words with quizzes: ${result.rows.length}`);
  
  await pool.end();
}

checkCounts();

