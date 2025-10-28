import { pool } from '../src/db/index.js';

async function fixDuplicateSettings() {
  console.log('🔄 Fixing duplicate quiz settings entries...\n');
  
  try {
    const client = await pool.connect();
    
    try {
      // Find all level 5 and 6 story quizzes
      const quizzes = await client.query(`
        SELECT id, word_id, level, options->>'settings' as settings_json
        FROM quiz_materials
        WHERE level IN (5, 6)
        AND question_type = 'story'
        ORDER BY word_id, level
      `);
      
      console.log(`Found ${quizzes.rows.length} level 5/6 story quizzes\n`);
      
      // Group by word_id and level to find duplicates
      const grouped = new Map();
      for (const quiz of quizzes.rows) {
        const key = `${quiz.word_id}-${quiz.level}`;
        if (!grouped.has(key)) {
          grouped.set(key, []);
        }
        grouped.get(key).push(quiz);
      }
      
      let deletedCount = 0;
      
      // For each group, keep the one with SHORT settings, delete the one with LONG settings
      for (const [key, entries] of grouped.entries()) {
        if (entries.length > 1) {
          console.log(`Word ID ${entries[0].word_id}, Level ${entries[0].level}: Found ${entries.length} entries`);
          
          // Parse settings to find the short one
          const withLength = entries.map(entry => {
            try {
              const settings = JSON.parse(entry.settings_json);
              const avgLength = settings.reduce((sum, s) => sum + s.length, 0) / settings.length;
              return { ...entry, avgLength };
            } catch {
              return { ...entry, avgLength: 9999 };
            }
          });
          
          // Sort by average length (shorter = better)
          withLength.sort((a, b) => a.avgLength - b.avgLength);
          
          // Delete all but the shortest
          for (let i = 1; i < withLength.length; i++) {
            console.log(`  ✗ Deleting entry ${withLength[i].id} (avg length: ${Math.round(withLength[i].avgLength)})`);
            await client.query('DELETE FROM quiz_materials WHERE id = $1', [withLength[i].id]);
            deletedCount++;
          }
          
          console.log(`  ✓ Keeping entry ${withLength[0].id} (avg length: ${Math.round(withLength[0].avgLength)})\n`);
        }
      }
      
      console.log(`✅ Deleted ${deletedCount} duplicate entries with long settings`);
      console.log('📝 All quizzes now use short setting labels!');
      
    } finally {
      client.release();
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixDuplicateSettings();

