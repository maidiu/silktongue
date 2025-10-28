const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function importAllData() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'maxvocab',
    database: 'vocab_atlas'
  });

  console.log('🔄 Starting complete data import...\n');

  try {
    // Clear existing quiz data
    console.log('🗑️  Clearing existing quiz data...');
    await connection.query('TRUNCATE TABLE quiz_materials');
    console.log('   ✓ Cleared\n');

    // Import Week 1
    console.log('📅 WEEK 1 (2025.10.17)');
    const week1Quiz = JSON.parse(fs.readFileSync('../weekly_quizzes/2025.10.17_quiz.json', 'utf8'));
    
    let w1Count = 0;
    for (const entry of week1Quiz) {
      await connection.query(
        'INSERT INTO quiz_materials (word, level, question_type, prompt, correct_answer, options, variant_data, reward_amount, difficulty) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          entry.word,
          entry.level,
          entry.question_type,
          entry.prompt,
          JSON.stringify(entry.correct_answer),
          JSON.stringify(entry.options),
          JSON.stringify(entry.variant_data),
          entry.reward_amount,
          entry.difficulty || 'medium'
        ]
      );
      w1Count++;
    }
    console.log(`   ✓ Imported ${w1Count} quiz entries`);

    // Import Week 2
    console.log('\n📅 WEEK 2 (2025.10.25)');
    const week2Quiz = JSON.parse(fs.readFileSync('../weekly_quizzes/2025.10.25_quiz.json', 'utf8'));
    
    let w2Count = 0;
    for (const entry of week2Quiz) {
      await connection.query(
        'INSERT INTO quiz_materials (word, level, question_type, prompt, correct_answer, options, variant_data, reward_amount, difficulty) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          entry.word,
          entry.level,
          entry.question_type,
          entry.prompt,
          JSON.stringify(entry.correct_answer),
          JSON.stringify(entry.options),
          JSON.stringify(entry.variant_data),
          entry.reward_amount,
          entry.difficulty || 'medium'
        ]
      );
      w2Count++;
    }
    console.log(`   ✓ Imported ${w2Count} quiz entries`);

    // Verify
    const [total] = await connection.query('SELECT COUNT(*) as count FROM quiz_materials');
    const [byWeek] = await connection.query(
      'SELECT word, COUNT(*) as count FROM quiz_materials GROUP BY word ORDER BY word'
    );

    console.log('\n✅ Import complete!');
    console.log(`   • Total entries in database: ${total[0].count}`);
    console.log(`   • Week 1: ${w1Count} entries`);
    console.log(`   • Week 2: ${w2Count} entries`);
    console.log(`   • Unique words: ${byWeek.length}`);
    console.log(`\n📊 Breakdown by word:`);
    for (const row of byWeek) {
      console.log(`   • ${row.word}: ${row.count} entries`);
    }

  } catch (error) {
    console.error('❌ Import error:', error);
    throw error;
  } finally {
    await connection.end();
  }
}

importAllData();
