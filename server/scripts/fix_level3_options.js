import { pool } from '../src/db/index.js';

async function fixLevel3Options() {
  try {
    console.log('🔄 Fixing Level 3 quiz options structure...\n');
    
    // Get all level 3 quizzes
    const result = await pool.query(`
      SELECT id, word_id, options, 
             jsonb_extract_path(options::jsonb, 'incorrect_answers') as incorrect_answers,
             jsonb_extract_path(options::jsonb, 'correct_answers') as correct_answers
      FROM quiz_materials 
      WHERE level = 3 AND question_type = 'definition'
    `);
    
    console.log(`Found ${result.rows.length} Level 3 definition quizzes\n`);
    
    for (const row of result.rows) {
      let options = row.options;
      
      // Parse if string
      if (typeof options === 'string') {
        try {
          options = JSON.parse(options);
        } catch (e) {
          console.log(`❌ Failed to parse options for quiz ${row.id}`);
          continue;
        }
      }
      
      // Check if incorrect_answers and correct_answers are at the top level
      if (options && (options.incorrect_answers || options.correct_answers)) {
        console.log(`✓ Quiz ${row.id} already has correct structure`);
        continue;
      }
      
      // Check if they're outside options (which means options is null or doesn't have them)
      // In this case, we need to query for them differently
      const detailResult = await pool.query(`
        SELECT id, word_id, 
               (options::jsonb->>'incorrect_answers')::jsonb as incorrect_in_options,
               (options::jsonb->>'correct_answers')::jsonb as correct_in_options,
               options::jsonb
        FROM quiz_materials 
        WHERE id = $1
      `, [row.id]);
      
      const detail = detailResult.rows[0];
      let optionsObj = detail.jsonb || {};
      
      // If incorrect_answers and correct_answers exist at top level but not in options
      if (optionsObj.incorrect_answers && optionsObj.correct_answers) {
        console.log(`  ℹ️  Quiz ${row.id} has answers at top level, keeping as is`);
        continue;
      }
      
      console.log(`  ⚠️  Quiz ${row.id} has incorrect structure, investigating...`);
      console.log(`  options:`, JSON.stringify(optionsObj, null, 2).substring(0, 200));
    }
    
    // Now let's check the raw structure of one problematic quiz
    const sampleResult = await pool.query(`
      SELECT id, word_id, options,
             jsonb_typeof(options::jsonb) as options_type,
             jsonb_object_keys(options::jsonb) as keys
      FROM quiz_materials 
      WHERE level = 3 AND question_type = 'definition'
      LIMIT 1
    `);
    
    console.log('\nSample quiz structure:');
    console.log(JSON.stringify(sampleResult.rows, null, 2));
    
    console.log('\n✅ Analysis complete!');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

fixLevel3Options();

