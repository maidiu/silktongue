import express from 'express';
import { pool } from '../db/index.js';
import { authenticateToken } from './auth.js';

const router = express.Router();

// Admin middleware
const requireAdmin = async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      'SELECT is_admin FROM users WHERE id = $1',
      [req.user.userId]
    );
    
    if (rows[0]?.is_admin) {
      next();
    } else {
      res.status(403).json({ error: 'Admin access required' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /api/quiz/admin/clear-cooldowns - Clear all Beast Mode cooldowns (admin only)
router.post('/admin/clear-cooldowns', authenticateToken, requireAdmin, async (req, res) => {
  try {
    await pool.query('DELETE FROM beast_mode_cooldowns');
    res.json({ success: true, message: 'All cooldowns cleared' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/buy-permanent-heart - Buy a permanent heart slot
router.post('/buy-permanent-heart', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Get current user stats
    const { rows } = await pool.query(
      'SELECT max_health_points FROM users WHERE id = $1',
      [userId]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const currentMax = rows[0].max_health_points;
    
    // Check if already at max
    if (currentMax >= 6) {
      return res.status(400).json({ error: 'Already at maximum hearts' });
    }
    
    // Calculate cost: 4th heart = 100, 5th heart = 300, 6th heart = 500
    const costs = { 3: 100, 4: 300, 5: 500 };
    const cost = costs[currentMax];
    
    // Check silk balance
    const { rows: statsRows } = await pool.query(
      'SELECT silk_balance FROM user_stats WHERE user_id = $1',
      [userId]
    );
    
    const silkBalance = statsRows[0]?.silk_balance || 0;
    
    if (silkBalance < cost) {
      return res.status(400).json({ error: 'Insufficient silk', required: cost, current: silkBalance });
    }
    
    // Deduct silk and increase max hearts
    await pool.query(
      'UPDATE user_stats SET silk_balance = silk_balance - $1 WHERE user_id = $2',
      [cost, userId]
    );
    
    await pool.query(
      'UPDATE users SET max_health_points = max_health_points + 1, health_points = health_points + 1 WHERE id = $1',
      [userId]
    );
    
    res.json({ 
      success: true, 
      newMaxHearts: currentMax + 1,
      cost: cost,
      newSilkBalance: silkBalance - cost
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/save-avatar - Save user avatar configuration
router.post('/save-avatar', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { avatarConfig } = req.body;
    
    if (!avatarConfig) {
      return res.status(400).json({ error: 'Avatar configuration is required' });
    }
    
    // Check silk balance (50 silk cost)
    const { rows: statsRows } = await pool.query(
      'SELECT silk_balance FROM user_stats WHERE user_id = $1',
      [userId]
    );
    
    const silkBalance = statsRows[0]?.silk_balance || 0;
    const cost = 50;
    
    if (silkBalance < cost) {
      return res.status(400).json({ error: 'Insufficient silk', required: cost, current: silkBalance });
    }
    
    // Deduct silk and save avatar config
    await pool.query(
      'UPDATE user_stats SET silk_balance = silk_balance - $1 WHERE user_id = $2',
      [cost, userId]
    );
    
    await pool.query(
      'UPDATE users SET avatar_config = $1 WHERE id = $2',
      [JSON.stringify(avatarConfig), userId]
    );
    
    res.json({ 
      success: true, 
      cost: cost,
      newSilkBalance: silkBalance - cost,
      avatarConfig: avatarConfig
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/quiz/word/:wordId - Get all quiz questions for a word
router.get('/word/:wordId', async (req, res) => {
  try {
    const { wordId } = req.params;
    
    const query = `
      SELECT 
        id, word_id, level, question_type, prompt,
        options, correct_answer, variant_data, reward_amount
      FROM quiz_materials
      WHERE word_id = $1
      ORDER BY level ASC
    `;
    
    const { rows } = await pool.query(query, [wordId]);
    
    // Parse JSON fields
    const parsedRows = rows.map(row => ({
      ...row,
      options: typeof row.options === 'string' ? JSON.parse(row.options) : row.options,
      variant_data: typeof row.variant_data === 'string' ? JSON.parse(row.variant_data) : row.variant_data
    }));
    
    res.json(parsedRows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/start/:wordId - Start or resume a quiz for a word
router.post('/start/:wordId', authenticateToken, async (req, res) => {
  try {
    const { wordId } = req.params;
    const userId = req.user.userId;
    
    // Check if quiz already exists
    let { rows: progressRows } = await pool.query(
      `SELECT id, current_level, health_remaining, silk_earned, completed_at
       FROM user_quiz_progress
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );
    
    if (progressRows.length > 0) {
      // Return existing progress
      return res.json(progressRows[0]);
    }
    
    // Create new quiz progress
    const { rows: newProgress } = await pool.query(
      `INSERT INTO user_quiz_progress (user_id, word_id, current_level, health_remaining)
       VALUES ($1, $2, 1, 5)
       RETURNING id, current_level, health_remaining, silk_earned, completed_at`,
      [userId, wordId]
    );
    
    res.json(newProgress[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/level-complete - Mark a level as complete and advance
router.post('/level-complete', authenticateToken, async (req, res) => {
  try {
    const { wordId, level, timeTaken } = req.body;
    const userId = req.user.userId;
    
    // Get current progress
    const { rows: progressRows } = await pool.query(
      `SELECT id, current_level, health_remaining, silk_earned, completed_at
       FROM user_quiz_progress
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );
    
    if (progressRows.length === 0) {
      return res.status(404).json({ error: 'Quiz not started' });
    }
    
    const progress = progressRows[0];
    
    // Don't allow re-completing
    if (progress.completed_at) {
      return res.status(400).json({ error: 'Quiz already completed' });
    }
    
    // Get the reward for this level
    const { rows: questionRows } = await pool.query(
      `SELECT reward_amount FROM quiz_materials WHERE word_id = $1 AND level = $2`,
      [wordId, level]
    );
    
    const reward = questionRows.length > 0 ? questionRows[0].reward_amount : 10;
    
    // Record the attempt
    await pool.query(
      `INSERT INTO quiz_attempts (quiz_id, level, is_correct)
       VALUES ($1, $2, true)`,
      [wordId, level]
    );
    
    // Check if this was the final level
    // Level 5 is the completion level, Level 6 is Beast Mode (separate challenge)
    const isComplete = level >= 5;
    const nextLevel = level < 5 ? level + 1 : null;
    
    // Update progress (per-user tracking only - no global updates)
    const updateQuery = isComplete
      ? `UPDATE user_quiz_progress
         SET current_level = $1,
             max_level_reached = $1,
             silk_earned = silk_earned + $2,
             completed_at = NOW()
         WHERE user_id = $3 AND word_id = $4
         RETURNING id, current_level, health_remaining, silk_earned, completed_at`
      : `UPDATE user_quiz_progress
         SET current_level = $1,
             max_level_reached = GREATEST(max_level_reached, $1),
             silk_earned = silk_earned + $2
         WHERE user_id = $3 AND word_id = $4
         RETURNING id, current_level, health_remaining, silk_earned, completed_at`;
    
    const { rows: updatedProgress } = await pool.query(
      updateQuery,
      [isComplete ? level : nextLevel, reward, userId, wordId]
    );
    
    // If complete, update user stats and silk balance
    if (isComplete) {
      await pool.query(
        `UPDATE user_stats
         SET silk_balance = silk_balance + $1,
             quizzes_completed = quizzes_completed + 1
         WHERE user_id = $2`,
        [updatedProgress[0].silk_earned, userId]
      );
      
      // Update user's silk balance in users table
      await pool.query(
        `UPDATE users
         SET silk_balance = silk_balance + $1
         WHERE id = $2`,
        [updatedProgress[0].silk_earned, userId]
      );
      
      // Mark the room as completed in the maps system
      await pool.query(
        `UPDATE user_room_unlocks
         SET completed_at = NOW()
         WHERE user_id = $1 
         AND room_id IN (SELECT id FROM rooms WHERE word_id = $2)
         AND completed_at IS NULL`,
        [userId, wordId]
      );
      
      // Update user statistics based on completion level
      if (level === 6) {
        // Beast Mode completion = mastered
        await pool.query(
          `UPDATE users 
           SET words_mastered = words_mastered + 1,
               total_silk_earned = total_silk_earned + $1
           WHERE id = $2`,
          [updatedProgress[0].silk_earned, userId]
        );
      } else if (level >= 3) {
        // Regular completion (levels 3-5) = learned
        await pool.query(
          `UPDATE users 
           SET words_learned = words_learned + 1,
               total_silk_earned = total_silk_earned + $1
           WHERE id = $2`,
          [updatedProgress[0].silk_earned, userId]
        );
      } else {
        // Just update silk for early levels
        await pool.query(
          `UPDATE users 
           SET total_silk_earned = total_silk_earned + $1
           WHERE id = $2`,
          [updatedProgress[0].silk_earned, userId]
        );
      }
      
      // Set up Beast Mode cooldown (1 hour from now)
      await pool.query(
        `INSERT INTO beast_mode_cooldowns (user_id, word_id, last_attempt, cooldown_until)
         VALUES ($1, $2, NOW(), NOW() + INTERVAL '1 hour')
         ON CONFLICT (user_id, word_id) 
         DO UPDATE SET last_attempt = NOW(), cooldown_until = NOW() + INTERVAL '1 hour'`,
        [userId, wordId]
      );
    }
    
    res.json({
      ...updatedProgress[0],
      reward,
      isComplete,
      nextLevel: isComplete ? null : nextLevel
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/fail - Record a failed attempt and deduct health
router.post('/fail', authenticateToken, async (req, res) => {
  try {
    const { wordId, level, healthLost = 1, timeTaken } = req.body;
    const userId = req.user.userId;
    
    // Get current progress
    const { rows: progressRows } = await pool.query(
      `SELECT id, current_level, health_remaining
       FROM user_quiz_progress
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );
    
    if (progressRows.length === 0) {
      return res.status(404).json({ error: 'Quiz not started' });
    }
    
    const progress = progressRows[0];
    const newHealth = Math.max(0, progress.health_remaining - healthLost);
    
    // Record the failed attempt
    await pool.query(
      `INSERT INTO quiz_attempts (quiz_id, level, is_correct)
       VALUES ($1, $2, false)`,
      [wordId, level]
    );
    
    // Update health in progress
    const { rows: updatedProgress } = await pool.query(
      `UPDATE user_quiz_progress
       SET health_remaining = $1
       WHERE user_id = $2 AND word_id = $3
       RETURNING id, current_level, health_remaining, silk_earned`,
      [newHealth, userId, wordId]
    );
    
    // Update user's health points in users table
    await pool.query(
      `UPDATE users
       SET health_points = health_points - $1
       WHERE id = $2`,
      [healthLost, userId]
    );
    
    // Update user stats
    await pool.query(
      `UPDATE user_stats
       SET total_health_lost = total_health_lost + $1
       WHERE user_id = $2`,
      [healthLost, userId]
    );
    
    res.json({
      ...updatedProgress[0],
      healthLost,
      isDead: newHealth <= 0
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/quiz/stats - Get user stats
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const { rows } = await pool.query(
      `SELECT silk_balance, words_mastered, quizzes_completed, total_health_lost
       FROM user_stats
       WHERE user_id = $1`,
      [userId]
    );
    
    if (rows.length === 0) {
      // Create default stats
      const { rows: newStats } = await pool.query(
        `INSERT INTO user_stats (user_id, silk_balance)
         VALUES ($1, 0)
         RETURNING silk_balance, words_mastered, quizzes_completed, total_health_lost`,
        [userId]
      );
      return res.json(newStats[0]);
    }
    
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/quiz/progress/:wordId - Get progress for a specific word
router.get('/progress/:wordId', authenticateToken, async (req, res) => {
  try {
    const { wordId } = req.params;
    const userId = req.user.userId;
    
    const { rows } = await pool.query(
      `SELECT current_level, max_level_reached, health_remaining, silk_earned, completed_at
       FROM user_quiz_progress
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );
    
    if (rows.length === 0) {
      return res.json(null);
    }
    
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/quiz/beast-mode/:wordId - Check if Beast mode is available
router.get('/beast-mode/:wordId', authenticateToken, async (req, res) => {
  try {
    const { wordId } = req.params;
    const userId = req.user.userId;

    // Check if user has completed the normal quiz
    const { rows: progressRows } = await pool.query(
      `SELECT completed_at FROM user_quiz_progress 
       WHERE user_id = $1 AND word_id = $2 AND completed_at IS NOT NULL`,
      [userId, wordId]
    );

    if (progressRows.length === 0) {
      return res.json({ 
        available: false, 
        reason: 'Must complete normal quiz first' 
      });
    }

    // Check cooldown
    const { rows: cooldownRows } = await pool.query(
      `SELECT cooldown_until FROM beast_mode_cooldowns 
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );

    const now = new Date();
    if (cooldownRows.length > 0) {
      const cooldownUntil = new Date(cooldownRows[0].cooldown_until);
      if (now < cooldownUntil) {
        return res.json({ 
          available: false, 
          reason: 'Cooldown active',
          cooldownUntil: cooldownUntil.toISOString()
        });
      }
    }

    // Get user's silk balance from user_stats table (same as stats endpoint)
    const { rows: statsRows } = await pool.query(
      `SELECT silk_balance FROM user_stats WHERE user_id = $1`,
      [userId]
    );

    const silkBalance = statsRows[0]?.silk_balance || 0;
    const maxWager = Math.min(silkBalance, 100); // Cap at 100 silk

    res.json({ 
      available: true, 
      maxWager,
      silkBalance 
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/beast-mode/:wordId - Start Beast mode attempt
router.post('/beast-mode/:wordId', authenticateToken, async (req, res) => {
  try {
    const { wordId } = req.params;
    const { wagerAmount } = req.body;
    const userId = req.user.userId;

    // Validate wager amount
    if (!wagerAmount || wagerAmount <= 0) {
      return res.status(400).json({ error: 'Invalid wager amount' });
    }

    // Check if user has enough silk from user_stats table
    const { rows: statsRows } = await pool.query(
      `SELECT silk_balance FROM user_stats WHERE user_id = $1`,
      [userId]
    );

    const silkBalance = statsRows[0]?.silk_balance || 0;
    if (wagerAmount > silkBalance) {
      return res.status(400).json({ error: 'Insufficient silk balance' });
    }

    // Check if Beast mode is available
    const { rows: progressRows } = await pool.query(
      `SELECT completed_at FROM user_quiz_progress 
       WHERE user_id = $1 AND word_id = $2 AND completed_at IS NOT NULL`,
      [userId, wordId]
    );

    if (progressRows.length === 0) {
      return res.status(400).json({ error: 'Must complete normal quiz first' });
    }

    // Check cooldown
    const { rows: cooldownRows } = await pool.query(
      `SELECT cooldown_until FROM beast_mode_cooldowns 
       WHERE user_id = $1 AND word_id = $2`,
      [userId, wordId]
    );

    const now = new Date();
    if (cooldownRows.length > 0) {
      const cooldownUntil = new Date(cooldownRows[0].cooldown_until);
      if (now < cooldownUntil) {
        return res.status(400).json({ error: 'Beast mode on cooldown' });
      }
    }

    // Deduct wager from user's silk balance in user_stats table
    await pool.query(
      `UPDATE user_stats SET silk_balance = silk_balance - $1 WHERE user_id = $2`,
      [wagerAmount, userId]
    );

    // Create Beast mode attempt record
    const { rows: attemptRows } = await pool.query(
      `INSERT INTO beast_mode_attempts (user_id, word_id, wager_amount, success)
       VALUES ($1, $2, $3, false)
       RETURNING id`,
      [userId, wordId, wagerAmount]
    );

    res.json({ 
      attemptId: attemptRows[0].id,
      wagerAmount,
      remainingSilk: silkBalance - wagerAmount
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/quiz/beast-mode/:attemptId/complete - Complete Beast mode attempt
router.post('/beast-mode/:attemptId/complete', authenticateToken, async (req, res) => {
  try {
    const { attemptId } = req.params;
    const { success } = req.body;
    const userId = req.user.userId;

    // Get the attempt details
    const { rows: attemptRows } = await pool.query(
      `SELECT user_id, word_id, wager_amount FROM beast_mode_attempts 
       WHERE id = $1 AND user_id = $2`,
      [attemptId, userId]
    );

    if (attemptRows.length === 0) {
      return res.status(404).json({ error: 'Beast mode attempt not found' });
    }

    const attempt = attemptRows[0];
    const silkEarned = success ? attempt.wager_amount * 2 : 0; // Double the wager on success

    // Update the attempt
    await pool.query(
      `UPDATE beast_mode_attempts 
       SET success = $1, silk_earned = $2, completed_at = NOW()
       WHERE id = $3`,
      [success, silkEarned, attemptId]
    );

    // Add silk to user's balance if successful
    if (success) {
      await pool.query(
        `UPDATE user_stats SET silk_balance = silk_balance + $1 WHERE user_id = $2`,
        [silkEarned, userId]
      );
      
      // Update user's mastered word count (only if not already counted from regular quiz completion)
      await pool.query(
        `UPDATE users SET words_mastered = words_mastered + 1 WHERE id = $1`,
        [userId]
      );
    }

    // Set cooldown
    await pool.query(
      `INSERT INTO beast_mode_cooldowns (user_id, word_id, last_attempt, cooldown_until)
       VALUES ($1, $2, NOW(), NOW() + INTERVAL '1 hour')
       ON CONFLICT (user_id, word_id) 
       DO UPDATE SET last_attempt = NOW(), cooldown_until = NOW() + INTERVAL '1 hour'`,
      [userId, attempt.word_id]
    );

    // Get updated user balance from user_stats table
    const { rows: statsRows } = await pool.query(
      `SELECT silk_balance FROM user_stats WHERE user_id = $1`,
      [userId]
    );

    res.json({
      success,
      silkEarned,
      wagerAmount: attempt.wager_amount,
      currentSilkBalance: statsRows[0].silk_balance,
      cooldownUntil: new Date(Date.now() + 60 * 60 * 1000).toISOString() // 1 hour from now
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;