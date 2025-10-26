import { pool } from './server/src/db/index.js';

async function checkLocalData() {
  try {
    console.log('\n🔍 Checking Local Database Content\n');
    
    // Check all tables
    const tables = [
      'vocab_entries',
      'word_timeline_events',
      'word_relations',
      'quiz_materials',
      'story_comprehension_questions',
      'causal_tags',
      'timeline_event_tags',
      'maps',
      'floors',
      'rooms',
      'root_families',
      'word_root_links',
      'citations',
      'derivations',
      'tokens',
      'purchases',
      'quiz_questions',
      'quizzes',
      'semantic_domains',
      'silk_transactions',
      'vocab_domain_links'
    ];
    
    for (const table of tables) {
      const result = await pool.query(`SELECT COUNT(*) as count FROM ${table}`);
      console.log(`${table}: ${result.rows[0].count} rows`);
    }
    
    // Detailed breakdown
    console.log('\n📊 Detailed breakdown:');
    
    // Vocab breakdown
    const vocabResult = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN is_mastered THEN 1 END) as mastered,
        COUNT(CASE WHEN NOT is_mastered THEN 1 END) as unmastered
      FROM vocab_entries
    `);
    console.log('\nVocab:', vocabResult.rows[0]);
    
    // Tower breakdown
    const mapsResult = await pool.query(`
      SELECT m.id, m.name, 
        COUNT(DISTINCT f.id) as floors,
        COUNT(DISTINCT r.id) as rooms
      FROM maps m
      LEFT JOIN floors f ON f.map_id = m.id
      LEFT JOIN rooms r ON r.floor_id = f.id
      GROUP BY m.id, m.name
    `);
    console.log('\nMaps with floors and rooms:');
    for (const row of mapsResult.rows) {
      console.log(`  Map ${row.id}: ${row.name} - ${row.floors} floors, ${row.rooms} rooms`);
    }
    
    // Story questions breakdown
    const storyResult = await pool.query(`
      SELECT COUNT(DISTINCT word_id) as words_with_stories,
        COUNT(*) as total_story_questions,
        AVG(story_count) as avg_stories_per_word
      FROM (
        SELECT word_id, COUNT(*) as story_count
        FROM story_comprehension_questions
        GROUP BY word_id
      ) sub
    `);
    console.log('\nStory Questions:', storyResult.rows[0]);
    
  } catch (error) {
    console.error('Error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

checkLocalData();

