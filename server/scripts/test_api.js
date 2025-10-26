import { pool } from '../src/db/index.js';

async function testAPI() {
  try {
    console.log('Testing API response for word ID 1...');
    
    // Test the timeline query directly
    const timelineQuery = `
      SELECT 
        id, century, event_text as story_text, sibling_words, context, created_at
      FROM word_timeline_events
      WHERE vocab_id = $1
      ORDER BY century ASC
    `;
    
    const { rows: timelineRows } = await pool.query(timelineQuery, [1]);
    
    console.log(`Found ${timelineRows.length} timeline events for word ID 1:`);
    timelineRows.forEach((row, index) => {
      console.log(`\nEvent ${index + 1}:`);
      console.log(`  Century: ${row.century}`);
      console.log(`  Story text: ${row.story_text?.substring(0, 100)}...`);
      console.log(`  Context: ${row.context}`);
      console.log(`  Sibling words: ${JSON.stringify(row.sibling_words)}`);
    });
    
    // Format as story array like the API does
    const story = timelineRows.map(event => ({
      century: event.century.toString(),
      story_text: event.story_text,
      sibling_words: event.sibling_words || [],
      context: event.context
    }));
    
    console.log(`\nFormatted story array length: ${story.length}`);
    console.log(`First story entry:`, JSON.stringify(story[0], null, 2));
    
  } catch (error) {
    console.error('Error testing API:', error);
  } finally {
    await pool.end();
  }
}

testAPI();
