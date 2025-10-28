import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from '../src/db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function importStoryTimeline() {
  try {
    console.log('Importing story timeline events for week 2 words...\n');
    
    // Read the weekly entries
    const weeklyEntries = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../../weekly_entries/2025.10.25.json'), 'utf8')
    );
    
    for (const entry of weeklyEntries) {
      if (!entry.word || !entry.story || !Array.isArray(entry.story)) {
        console.log(`⚠ Skipping ${entry.word}: no story data`);
        continue;
      }
      
      // Look up the word_id
      const wordRes = await pool.query('SELECT id FROM vocab_entries WHERE word = $1', [entry.word]);
      if (wordRes.rows.length === 0) {
        console.log(`⚠ Word "${entry.word}" not found in database`);
        continue;
      }
      const word_id = wordRes.rows[0].id;
      
      console.log(`\nProcessing: ${entry.word} (ID: ${word_id})`);
      
      // Delete existing timeline events for this word
      await pool.query('DELETE FROM word_timeline_events WHERE vocab_id = $1', [word_id]);
      
      let eventCount = 0;
      
      // Import each story part as a timeline event
      for (const storyPart of entry.story) {
        if (!storyPart.century || !storyPart.story_text) {
          console.log(`  ⚠ Skipping incomplete story part for century ${storyPart.century}`);
          continue;
        }
        
        // Parse century (handle formats like "1", "14", etc.)
        let centuryInt = parseInt(storyPart.century);
        if (isNaN(centuryInt)) {
          console.log(`  ⚠ Could not parse century: ${storyPart.century}`);
          continue;
        }
        
        // Insert timeline event
        const insertQuery = `
          INSERT INTO word_timeline_events 
          (vocab_id, century, event_text, sibling_words, context, language_stage, semantic_focus)
          VALUES ($1, $2, $3, $4, $5, $6, $7)
        `;
        
        const values = [
          word_id,
          centuryInt,
          storyPart.story_text,
          storyPart.sibling_words || [],
          storyPart.context || '',
          storyPart.language_stage || null,
          storyPart.semantic_focus || null
        ];
        
        await pool.query(insertQuery, values);
        eventCount++;
        console.log(`  ✓ Added ${centuryInt}th century event`);
      }
      
      console.log(`  Total: ${eventCount} timeline events`);
      
      // Also update the main vocab entry with story fields
      const updateQuery = `
        UPDATE vocab_entries 
        SET 
          story_intro = $1,
          structural_analysis = $2,
          story_text = $3
        WHERE id = $4
      `;
      
      await pool.query(updateQuery, [
        entry.story_intro || null,
        entry.structural_analysis || null,
        entry.story_text || null,
        word_id
      ]);
      
      console.log(`  ✓ Updated vocab entry with story metadata`);
    }
    
    console.log('\n✅ Successfully imported all story timeline events!');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

importStoryTimeline();

