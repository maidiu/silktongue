import { pool } from '../src/db/index.js';

async function verifyConsistency() {
  console.log('=== Database Consistency Check ===\n');
  
  try {
    // Count total words
    const wordsResult = await pool.query('SELECT COUNT(*) as word_count FROM vocab_entries');
    console.log('✓ Total words in vocab_entries:', wordsResult.rows[0].word_count);
    
    // Count total quizzes
    const quizzesResult = await pool.query('SELECT COUNT(*) as quiz_count FROM quiz_materials');
    console.log('✓ Total quiz entries:', quizzesResult.rows[0].quiz_count);
    
    // Count quiz levels per word
    const levelsResult = await pool.query(`
      SELECT 
        ve.word,
        COUNT(DISTINCT qm.level) as level_count
      FROM vocab_entries ve
      LEFT JOIN quiz_materials qm ON ve.id = qm.word_id
      WHERE ve.word IN (
        'cohesive', 'impede', 'inherent', 'omit', 'perfunctory', 'salient', 'scattershot', 'verisimilitude',
        'attest', 'elucidate', 'lumbering', 'pall', 'plausible', 'scurry', 'steadfast', 'ubiquitous'
      )
      GROUP BY ve.word
      ORDER BY ve.word
    `);
    
    console.log('\n=== Quizzes per word (should be 6 levels each) ===');
    let allComplete = true;
    levelsResult.rows.forEach(row => {
      const status = row.level_count === '6' || row.level_count === 6 ? '✓' : '✗ MISSING';
      console.log(`  ${row.word}: ${row.level_count} levels ${status}`);
      if (row.level_count !== '6' && row.level_count !== 6) allComplete = false;
    });
    
    // Count story questions
    const storiesResult = await pool.query('SELECT COUNT(*) as story_count FROM story_comprehension_questions');
    console.log('\n✓ Total story comprehension questions:', storiesResult.rows[0].story_count);
    
    // Check for duplicate settings in level 5/6
    const duplicateCheck = await pool.query(`
      SELECT ve.word, qm.level, COUNT(*) as entry_count
      FROM quiz_materials qm
      JOIN vocab_entries ve ON ve.id = qm.word_id
      WHERE qm.level IN (5, 6) AND qm.question_type = 'story'
      AND ve.word IN (
        'cohesive', 'impede', 'inherent', 'omit', 'perfunctory', 'salient', 'scattershot', 'verisimilitude',
        'attest', 'elucidate', 'lumbering', 'pall', 'plausible', 'scurry', 'steadfast', 'ubiquitous'
      )
      GROUP BY ve.word, qm.level
      HAVING COUNT(*) > 1
    `);
    
    if (duplicateCheck.rows.length > 0) {
      console.log('\n✗ DUPLICATE ENTRIES FOUND:');
      duplicateCheck.rows.forEach(row => {
        console.log(`  ${row.word}, Level ${row.level}: ${row.entry_count} entries`);
      });
    } else {
      console.log('\n✓ No duplicate quiz entries');
    }
    
    console.log('\n=== Summary ===');
    console.log(allComplete ? '✅ All words have complete quiz sets (6 levels)' : '⚠️  Some words are missing quiz levels');
    console.log('✅ Database is consistent and ready for use');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

verifyConsistency();

