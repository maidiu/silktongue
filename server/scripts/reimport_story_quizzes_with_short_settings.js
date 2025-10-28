import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const quizFiles = [
  path.join(__dirname, '../../weekly_quizzes/2025.10.17_quiz.json'),
  path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json')
];

async function reimportStoryQuizzes() {
  console.log('🔄 Re-importing Level 5 & 6 story quizzes with correct short settings...\n');
  let updatedCount = 0;

  for (const filePath of quizFiles) {
    try {
      const quizData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      const weekName = path.basename(filePath, '.json');
      console.log(`Processing ${weekName}...`);

      for (const quiz of quizData) {
        if ((quiz.level === 5 || quiz.level === 6) && quiz.question_type === 'story') {
          // Get the word_id from vocab_entries
          const wordResult = await pool.query(
            'SELECT id FROM vocab_entries WHERE word = $1',
            [quiz.word]
          );

          if (wordResult.rows.length === 0) {
            console.warn(`  ⚠️  Word "${quiz.word}" not found in vocab_entries. Skipping.`);
            continue;
          }

          const wordId = wordResult.rows[0].id;

          // Update the quiz_materials entry with the correct options
          const updateResult = await pool.query(
            `UPDATE quiz_materials
             SET options = $1,
                 correct_answer = $2
             WHERE word_id = $3 AND level = $4 AND question_type = $5`,
            [
              JSON.stringify(quiz.options),
              JSON.stringify(quiz.correct_answer),
              wordId,
              quiz.level,
              quiz.question_type
            ]
          );

          if (updateResult.rowCount > 0) {
            updatedCount++;
            console.log(`  ✓ Updated ${quiz.word} Level ${quiz.level}`);
            console.log(`    Settings: [${quiz.options.settings.map(s => `"${s.substring(0, 30)}..."`).join(', ')}]`);
          }
        }
      }
    } catch (error) {
      console.error(`Error processing ${filePath}:`, error);
    }
  }

  console.log(`\n✅ Re-imported ${updatedCount} story quizzes with correct short settings`);
  await pool.end();
}

reimportStoryQuizzes();

