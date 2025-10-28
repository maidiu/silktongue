import express from 'express';
import { pool } from '../db/index.js';
import { authenticateToken } from './auth.js';

const router = express.Router();

// GET /api/vocab/stats - Get user statistics
router.get('/stats', async (req, res) => {
  try {
    const query = `
      SELECT 
        COUNT(*) as total_words,
        COUNT(CASE WHEN learning_status = 'learned' THEN 1 END) as learned_count,
        COUNT(CASE WHEN learning_status = 'mastered' THEN 1 END) as mastered_count,
        COUNT(CASE WHEN learning_status = 'unmastered' THEN 1 END) as unmastered_count
      FROM vocab_entries
    `;
    
    const { rows } = await pool.query(query);
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/vocab/scoreboard - Get top users scoreboard
router.get('/scoreboard', async (req, res) => {
  try {
    const query = `
      SELECT 
        u.username,
        u.silk_balance,
        u.words_learned,
        u.words_mastered,
        u.total_silk_earned,
        u.avatar_config,
        COUNT(DISTINCT CASE WHEN up.completed_at IS NOT NULL THEN up.word_id END) as quizzes_completed
      FROM users u
      LEFT JOIN user_quiz_progress up ON u.id = up.user_id
      WHERE u.username IS NOT NULL
      GROUP BY u.id, u.username, u.silk_balance, u.words_learned, u.words_mastered, u.total_silk_earned, u.avatar_config
      ORDER BY u.total_silk_earned DESC, u.words_mastered DESC, u.words_learned DESC
      LIMIT 10
    `;
    
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/vocab/beast-mode-status/:wordId - Check beast mode status for a word
router.get('/beast-mode-status/:wordId', authenticateToken, async (req, res) => {
  try {
    const { wordId } = req.params;
    const userId = req.user.userId;
    
    // Check if THIS user has completed Level 5 for this word
    const query = `
      SELECT 
        up.completed_at,
        bmc.cooldown_until,
        CASE 
          WHEN bmc.cooldown_until > NOW() THEN 'cooldown'
          WHEN up.completed_at IS NOT NULL THEN 'available'
          ELSE 'locked'
        END as status
      FROM user_quiz_progress up
      LEFT JOIN beast_mode_cooldowns bmc ON up.user_id = bmc.user_id AND up.word_id = bmc.word_id
      WHERE up.user_id = $1 AND up.word_id = $2 AND up.completed_at IS NOT NULL
    `;
    
    const { rows } = await pool.query(query, [userId, wordId]);
    
    if (rows.length === 0) {
      res.json({ status: 'locked' });
    } else {
      res.json(rows[0]);
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/vocab - List words with sorting and filtering
router.get('/', async (req, res) => {
  try {
    const { sort = 'date', filter = 'all' } = req.query;
    
    let orderBy = 'date_added DESC';
    if (sort === 'alpha') {
      orderBy = 'word ASC';
    }
    
    let whereClause = '';
    if (filter === 'learned') {
      whereClause = 'WHERE learning_status = \'learned\' OR learning_status = \'mastered\'';
    } else if (filter === 'unlearned') {
      whereClause = 'WHERE learning_status = \'unmastered\'';
    }
    
    const query = `
      SELECT 
        id, word, part_of_speech, modern_definition, 
        usage_example, synonyms, antonyms, collocations,
        french_equivalent, russian_equivalent, cefr_level,
        pronunciation, is_mastered, learning_status, date_added,
        definitions, variant_forms, common_collocations,
        french_synonyms, french_root_cognates,
        russian_synonyms, russian_root_cognates
      FROM vocab_entries 
      ${whereClause}
      ORDER BY ${orderBy}
    `;
    
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/vocab/search - Search words
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.json([]);
    }
    
    const query = `
      SELECT 
        id, word, part_of_speech, modern_definition, 
        usage_example, is_mastered
      FROM vocab_entries
      WHERE 
        word ILIKE $1 OR 
        modern_definition ILIKE $1 OR
        story_text ILIKE $1
      ORDER BY 
        CASE 
          WHEN word ILIKE $1 THEN 1
          WHEN modern_definition ILIKE $1 THEN 2
          ELSE 3
        END,
        word ASC
      LIMIT 10
    `;
    
    const { rows } = await pool.query(query, [`%${q}%`]);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/vocab/:id - Get single vocab entry with full timeline
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log('🔥 API HIT: /api/vocab/' + id);
    
    // Get the vocab entry (schema matches!)
    const entryQuery = `
      SELECT 
        id, word, part_of_speech, modern_definition, 
        usage_example, synonyms, antonyms, collocations,
        french_equivalent, russian_equivalent, cefr_level,
        pronunciation, story_text, contrastive_opening,
        structural_analysis, common_collocations, is_mastered, 
        date_added, metadata, story_intro,
        definitions, variant_forms, semantic_field,
        english_synonyms, english_antonyms,
        french_synonyms, french_root_cognates,
        russian_synonyms, russian_root_cognates, common_phrases
      FROM vocab_entries
      WHERE id = $1
    `;
    
    const { rows: entryRows } = await pool.query(entryQuery, [id]);
    
    if (entryRows.length === 0) {
      return res.status(404).json({ error: 'Word not found' });
    }
    
    const entry = entryRows[0];
    
    // Get timeline events (FIXED column names to match schema)
    const timelineQuery = `
      SELECT 
        id, century, event_text, sibling_words, context, created_at
      FROM word_timeline_events
      WHERE vocab_id = $1
      ORDER BY century ASC
    `;
    
    const { rows: timelineRows } = await pool.query(timelineQuery, [id]);
    
    // Get causal tags for each timeline event
    for (let event of timelineRows) {
      const tagsQuery = `
        SELECT ct.tag_name, ct.description
        FROM timeline_event_tags tet
        JOIN causal_tags ct ON tet.tag_id = ct.id
        WHERE tet.event_id = $1
      `;
      const { rows: tagRows } = await pool.query(tagsQuery, [event.id]);
      event.causal_tags = tagRows.map(t => t.tag_name);
    }
    
    // Get word relations (FIXED to use source_id/target_id)
    const relationsQuery = `
      SELECT 
        ve.id, ve.word, ve.modern_definition, wr.relation_type
      FROM word_relations wr
      JOIN vocab_entries ve ON wr.target_id = ve.id
      WHERE wr.source_id = $1
    `;
    
    const { rows: relationRows } = await pool.query(relationsQuery, [id]);
    
    // Get root family (FIXED to use vocab_id and gloss)
    const rootQuery = `
      SELECT rf.root_word, rf.language, rf.gloss
      FROM word_root_links wrl
      JOIN root_families rf ON wrl.root_id = rf.id
      WHERE wrl.vocab_id = $1
    `;
    
    const { rows: rootRows } = await pool.query(rootQuery, [id]);
    
    // Get semantic domains
    const domainsQuery = `
      SELECT sd.name, sd.description
      FROM vocab_domain_links vdl
      JOIN semantic_domains sd ON vdl.domain_id = sd.id
      WHERE vdl.vocab_id = $1
    `;
    
    const { rows: domainRows } = await pool.query(domainsQuery, [id]);
    
    // Get derivations (parent/child relationships)
    const derivationsQuery = `
      SELECT 
        ve.word AS related_word,
        d.relation_type,
        d.notes,
        'parent' AS direction
      FROM derivations d
      JOIN vocab_entries ve ON d.parent_vocab_id = ve.id
      WHERE d.child_vocab_id = $1
      
      UNION ALL
      
      SELECT 
        ve.word AS related_word,
        d.relation_type,
        d.notes,
        'child' AS direction
      FROM derivations d
      JOIN vocab_entries ve ON d.child_vocab_id = ve.id
      WHERE d.parent_vocab_id = $1
    `;
    
    const { rows: derivationRows } = await pool.query(derivationsQuery, [id]);
    
    // Format timeline events as story array
    const story = timelineRows.map(event => ({
      century: event.century.toString(),
      story_text: event.event_text,
      sibling_words: event.sibling_words || [],
      context: event.context
    }));
    
    console.log('API: Timeline rows:', timelineRows.length);
    console.log('API: Story array:', story.length);
    console.log('API: First story entry:', story[0]);
    
    // Parse JSON fields
    const parsedEntry = {
      ...entry,
      definitions: entry.definitions ? (typeof entry.definitions === 'string' ? JSON.parse(entry.definitions) : entry.definitions) : {},
      timeline_events: timelineRows,
      relations: relationRows,
      roots: rootRows,
      domains: domainRows,
      derivations: derivationRows
    };
    
    // Explicitly set story to the array we created
    parsedEntry.story = story;

    console.log('API: Final response story length:', parsedEntry.story?.length);
    console.log('API: Story array:', JSON.stringify(parsedEntry.story));
    res.json(parsedEntry);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/vocab/:id/learned - Toggle learned status
router.patch('/:id/learned', async (req, res) => {
  try {
    const { id } = req.params;
    const { is_mastered } = req.body;
    
    const query = `
      UPDATE vocab_entries 
      SET is_mastered = $1 
      WHERE id = $2 
      RETURNING id, is_mastered
    `;
    
    const { rows } = await pool.query(query, [is_mastered, id]);
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Word not found' });
    }
    
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});
// POST /api/vocab/:id/definition - Save user's initial definition
router.post('/:id/definition', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log('Saving definition for userId:', userId);
    const wordId = parseInt(req.params.id);
    const { definition } = req.body;
    
    if (!definition || definition.trim().length === 0) {
      return res.status(400).json({ error: 'Definition is required' });
    }
    
    // Create or update user's initial definition
    const query = `
      INSERT INTO user_word_definitions (user_id, word_id, initial_definition, created_at)
      VALUES ($1, $2, $3, NOW())
      ON CONFLICT (user_id, word_id)
      DO UPDATE SET initial_definition = $3, updated_at = NOW()
      RETURNING *
    `;
    
    const { rows } = await pool.query(query, [userId, wordId, definition.trim()]);
    
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('Error saving definition:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get story comprehension questions for a word
router.get('/:id/story-questions', authenticateToken, async (req, res) => {
  try {
    const wordId = parseInt(req.params.id);
    console.log('📚 Fetching story questions for wordId:', wordId);
    
    const query = `
      SELECT 
        scq.id,
        scq.century,
        scq.question,
        scq.options,
        scq.correct_answer,
        scq.explanation
      FROM story_comprehension_questions scq
      WHERE scq.word_id = $1
      ORDER BY 
        CASE 
          WHEN scq.century ~ '^-?[0-9]+$' THEN scq.century::int
          WHEN scq.century ~ '^[0-9]+-[0-9]+' THEN SPLIT_PART(scq.century, '-', 1)::int
          ELSE 999
        END ASC
    `;
    
    const { rows } = await pool.query(query, [wordId]);
    
    console.log('✅ Found', rows.length, 'story questions for word', wordId);
    
    // Parse JSON options if they're strings
    const parsedRows = rows.map(row => ({
      ...row,
      options: typeof row.options === 'string' ? JSON.parse(row.options) : row.options
    }));
    
    res.json(parsedRows);
  } catch (err) {
    console.error('❌ Error fetching story questions:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Submit story comprehension answer
router.post('/:id/story-answer', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const wordId = parseInt(req.params.id);
    const { questionId, userAnswer } = req.body;
    
    console.log('📝 Story answer submission:', { userId, wordId, questionId, userAnswer });
    
    // Get the correct answer
    const correctQuery = `
      SELECT correct_answer, explanation FROM story_comprehension_questions 
      WHERE id = $1 AND word_id = $2
    `;
    const { rows: correctRows } = await pool.query(correctQuery, [questionId, wordId]);
    
    console.log('✅ Found', correctRows.length, 'rows for question', questionId);
    
    if (correctRows.length === 0) {
      console.error('❌ Question not found:', questionId, 'for word', wordId);
      return res.status(404).json({ error: 'Question not found' });
    }
    
    const correctAnswer = correctRows[0].correct_answer;
    const isCorrect = userAnswer.trim().toLowerCase() === correctAnswer.toLowerCase();
    
    console.log('🎯 Answer check:', { userAnswer, correctAnswer, isCorrect });
    
    // Record the attempt
    const insertQuery = `
      INSERT INTO user_story_study_attempts 
      (user_id, word_id, question_id, user_answer, is_correct)
      VALUES ($1, $2, $3, $4, $5)
    `;
    
    await pool.query(insertQuery, [userId, wordId, questionId, userAnswer, isCorrect]);
    
    console.log('✅ Attempt recorded');
    
    res.json({ 
      isCorrect, 
      correctAnswer,
      explanation: correctRows[0].explanation || 'No explanation available'
    });
  } catch (err) {
    console.error('❌ Error submitting story answer:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Complete story study and award silk
router.post('/:id/complete-story', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const wordId = parseInt(req.params.id);
    
    // Check if user has already completed this story
    const progressQuery = `
      SELECT story_completed, times_studied, total_silk_earned
      FROM user_story_study_progress 
      WHERE user_id = $1 AND word_id = $2
    `;
    const { rows: progressRows } = await pool.query(progressQuery, [userId, wordId]);
    
    let silkReward = 0;
    let isFirstCompletion = false;
    
    if (progressRows.length === 0) {
      // First time studying
      silkReward = 10;
      isFirstCompletion = true;
      
      // Insert new progress record
      const insertQuery = `
        INSERT INTO user_story_study_progress 
        (user_id, word_id, story_completed, first_completion_at, times_studied, total_silk_earned)
        VALUES ($1, $2, true, CURRENT_TIMESTAMP, 1, $3)
      `;
      await pool.query(insertQuery, [userId, wordId, silkReward]);
    } else {
      const progress = progressRows[0];
      
      if (progress.times_studied === 0) {
        // First completion
        silkReward = 10;
        isFirstCompletion = true;
      } else if (progress.times_studied === 1) {
        // Second time
        silkReward = 5;
      } else {
        // Third+ time, no reward
        silkReward = 0;
      }
      
      // Update progress
      const updateQuery = `
        UPDATE user_story_study_progress 
        SET 
          times_studied = times_studied + 1,
          total_silk_earned = total_silk_earned + $3,
          last_studied_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $1 AND word_id = $2
      `;
      await pool.query(updateQuery, [userId, wordId, silkReward]);
    }
    
    // Award silk to user
    if (silkReward > 0) {
      const silkQuery = `
        UPDATE user_stats 
        SET silk_balance = silk_balance + $2
        WHERE user_id = $1
      `;
      await pool.query(silkQuery, [userId, silkReward]);
    }
    
    res.json({ 
      success: true, 
      silkReward,
      isFirstCompletion,
      message: silkReward > 0 ? `You earned ${silkReward} silk for completing the story!` : 'Story completed (no additional silk reward)'
    });
  } catch (err) {
    console.error('Error completing story:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get story study progress for a word
router.get('/:id/story-progress', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const wordId = parseInt(req.params.id);
    
    const query = `
      SELECT 
        story_completed,
        first_completion_at,
        last_studied_at,
        times_studied,
        total_silk_earned
      FROM user_story_study_progress 
      WHERE user_id = $1 AND word_id = $2
    `;
    
    const { rows } = await pool.query(query, [userId, wordId]);
    
    if (rows.length === 0) {
      res.json({
        story_completed: false,
        first_completion_at: null,
        last_studied_at: null,
        times_studied: 0,
        total_silk_earned: 0
      });
    } else {
      res.json(rows[0]);
    }
  } catch (err) {
    console.error('Error fetching story progress:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
