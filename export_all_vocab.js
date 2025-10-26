import { pool } from './server/src/db/index.js';
import fs from 'fs';

async function exportAllVocab() {
  try {
    console.log('\n📤 Exporting ALL Vocabulary Data from Local Database\n');
    
    // Get all words
    const { rows: vocabRows } = await pool.query(`
      SELECT 
        id, word, part_of_speech, modern_definition, usage_example, 
        synonyms, antonyms, collocations, french_equivalent, russian_equivalent,
        cefr_level, pronunciation, is_mastered, learning_status, 
        date_added, story_text, contrastive_opening, structural_analysis
      FROM vocab_entries 
      ORDER BY id
    `);
    
    console.log(`Found ${vocabRows.length} words in database\n`);
    
    // Convert to INSERT statements
    const sqlCommands = [];
    sqlCommands.push(`-- Vocabulary Entries Export`);
    sqlCommands.push(`-- Generated on ${new Date().toISOString()}`);
    sqlCommands.push(`-- Total entries: ${vocabRows.length}\n`);
    
    // Clear existing data
    sqlCommands.push(`-- Clear existing data (optional)`);
    sqlCommands.push(`-- TRUNCATE TABLE vocab_entries CASCADE;\n`);
    
    sqlCommands.push(`-- Insert all vocabulary entries\n`);
    
    for (const entry of vocabRows) {
      const vals = [
        entry.id,
        entry.word,
        entry.part_of_speech,
        entry.modern_definition,
        entry.usage_example,
        entry.synonyms ? `'${JSON.stringify(entry.synonyms).replace(/'/g, "''")}'::jsonb` : 'NULL',
        entry.antonyms ? `'${JSON.stringify(entry.antonyms).replace(/'/g, "''")}'::jsonb` : 'NULL',
        entry.collocations ? `'${JSON.stringify(entry.collocations).replace(/'/g, "''")}'::jsonb` : "'{}'::jsonb",
        entry.french_equivalent,
        entry.russian_equivalent,
        entry.cefr_level,
        entry.pronunciation,
        entry.is_mastered,
        entry.learning_status,
        entry.date_added,
        entry.story_text,
        entry.contrastive_opening,
        entry.structural_analysis
      ];
      
      sqlCommands.push(`INSERT INTO vocab_entries (id, word, part_of_speech, modern_definition, usage_example, synonyms, antonyms, collocations, french_equivalent, russian_equivalent, cefr_level, pronunciation, is_mastered, learning_status, date_added, story_text, contrastive_opening, structural_analysis) VALUES`);
      sqlCommands.push(`(${vals.map(v => v === null ? 'NULL' : v).join(', ')}) ON CONFLICT (id) DO NOTHING;`);
      sqlCommands.push(``);
    }
    
    // Write to file
    const sqlFile = 'vocab_data_export.sql';
    fs.writeFileSync(sqlFile, sqlCommands.join('\n'));
    
    console.log(`✅ Vocabulary data exported to: ${sqlFile}`);
    console.log(`   - ${vocabRows.length} entries`);
    
    // Also get quiz data
    console.log('\n📤 Exporting ALL Quiz Data\n');
    const { rows: quizRows } = await pool.query(`SELECT * FROM quiz_materials ORDER BY word_id, level`);
    
    const quizSql = [];
    quizSql.push(`-- Quiz Materials Export`);
    quizSql.push(`-- Total quiz questions: ${quizRows.length}\n`);
    
    for (const quiz of quizRows) {
      const opts = quiz.options ? JSON.stringify(quiz.options).replace(/'/g, "''") : 'NULL';
      const vars = quiz.variant_data ? JSON.stringify(quiz.variant_data).replace(/'/g, "''") : 'NULL';
      
      quizSql.push(`INSERT INTO quiz_materials (word_id, level, question_type, prompt, options, correct_answer, variant_data, reward_amount, created_at, updated_at) VALUES`);
      quizSql.push(`(${quiz.word_id}, ${quiz.level}, '${quiz.question_type}', '${quiz.prompt.replace(/'/g, "''")}', '${opts}'::jsonb, '${quiz.correct_answer}', '${vars}'::jsonb, ${quiz.reward_amount}, '${quiz.created_at}', '${quiz.updated_at}') ON CONFLICT (word_id, level) DO NOTHING;`);
    }
    
    const quizFile = 'quiz_data_export.sql';
    fs.writeFileSync(quizFile, quizSql.join('\n'));
    console.log(`✅ Quiz data exported to: ${quizFile}`);
    console.log(`   - ${quizRows.length} questions`);
    
    // Get story comprehension
    console.log('\n📤 Exporting ALL Story Comprehension Questions\n');
    const { rows: storyRows } = await pool.query(`SELECT * FROM story_comprehension_questions ORDER BY word_id, century`);
    
    const storySql = [];
    storySql.push(`-- Story Comprehension Questions Export`);
    storySql.push(`-- Total questions: ${storyRows.length}\n`);
    
    for (const story of storyRows) {
      const opts = JSON.stringify(story.options).replace(/'/g, "''");
      storySql.push(`INSERT INTO story_comprehension_questions (word_id, century, question, options, correct_answer, explanation, created_at, updated_at) VALUES`);
      storySql.push(`(${story.word_id}, '${story.century}', '${story.question.replace(/'/g, "''")}', '${opts}'::jsonb, '${story.correct_answer}', '${story.explanation.replace(/'/g, "''")}', '${story.created_at}', '${story.updated_at}') ON CONFLICT (word_id, century) DO NOTHING;`);
    }
    
    const storyFile = 'story_data_export.sql';
    fs.writeFileSync(storyFile, storySql.join('\n'));
    console.log(`✅ Story comprehension data exported to: ${storyFile}`);
    console.log(`   - ${storyRows.length} questions`);
    
    console.log(`\n✅ All data exported successfully!`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

exportAllVocab();
