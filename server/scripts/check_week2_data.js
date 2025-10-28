import { pool } from '../src/db/index.js';

async function checkWeek2Data() {
  try {
    const words = ['ubiquitous', 'plausible', 'elucidate'];
    
    for (const word of words) {
      console.log(`\n${'='.repeat(60)}`);
      console.log(`Checking: ${word}`);
      console.log('='.repeat(60));
      
      // Get word ID
      const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [word]);
      if (wordRes.rows.length === 0) {
        console.log('❌ Word not found');
        continue;
      }
      const word_id = wordRes.rows[0].id;
      console.log(`Word ID: ${word_id}`);
      
      // Check quiz materials
      const quizRes = await pool.query(
        'SELECT level, question_type, prompt FROM quiz_materials WHERE word_id = $1 ORDER BY level',
        [word_id]
      );
      console.log(`\nQuiz materials: ${quizRes.rows.length}`);
      quizRes.rows.forEach(r => {
        console.log(`  Level ${r.level}: ${r.question_type} - ${r.prompt.substring(0, 50)}...`);
      });
      
      // Check timeline events
      const timelineRes = await pool.query(
        'SELECT century, event_text FROM word_timeline_events WHERE vocab_id = $1 ORDER BY century',
        [word_id]
      );
      console.log(`\nTimeline events: ${timelineRes.rows.length}`);
      timelineRes.rows.forEach(r => {
        console.log(`  Century ${r.century}: ${r.event_text.substring(0, 80)}...`);
      });
      
      // Check story questions
      const storyQRes = await pool.query(
        'SELECT century, question FROM story_comprehension_questions WHERE word_id = $1',
        [word_id]
      );
      console.log(`\nStory comprehension questions: ${storyQRes.rows.length}`);
      storyQRes.rows.forEach(r => {
        console.log(`  Century ${r.century}: ${r.question.substring(0, 80)}...`);
      });
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

checkWeek2Data();

