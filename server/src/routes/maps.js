import express from 'express';
import { pool } from '../db/index.js';
import { authenticateToken } from './auth.js';

const router = express.Router();

// Get all maps available to the user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { rows: maps } = await pool.query(
      'SELECT * FROM maps ORDER BY id'
    );
    
    res.json(maps);
  } catch (error) {
    console.error('Error fetching maps:', error);
    res.status(500).json({ error: 'Failed to fetch maps' });
  }
});

// Get a specific map with its floors and rooms
router.get('/:mapId', authenticateToken, async (req, res) => {
  try {
    const { mapId } = req.params;
    const userId = req.user.userId;
    
    // Get map details
    const { rows: mapRows } = await pool.query(
      'SELECT * FROM maps WHERE id = $1',
      [mapId]
    );
    
    if (mapRows.length === 0) {
      return res.status(404).json({ error: 'Map not found' });
    }
    
    const map = mapRows[0];
    
    // ============================================================================
    // HARD-CODED: First room (impede) is ALWAYS unlocked for ALL users, forever
    // This runs every time the map loads, ensuring impede is always accessible
    // ============================================================================
    await pool.query(`
      INSERT INTO user_room_unlocks (user_id, room_id, silk_spent)
      SELECT $1, r.id, 0
      FROM rooms r
      JOIN floors f ON r.floor_id = f.id
      WHERE f.map_id = $2 
        AND f.floor_number = 1 
        AND r.room_number = 1
        AND NOT EXISTS (
          SELECT 1 FROM user_room_unlocks 
          WHERE user_id = $1 AND room_id = r.id
        )
    `, [userId, mapId]);
    
    // Get floors with rooms
    const { rows: floors } = await pool.query(`
      SELECT 
        f.*,
        json_agg(
          json_build_object(
            'id', r.id,
            'room_number', r.room_number,
            'name', r.name,
            'description', r.description,
            'silk_cost', r.silk_cost,
            'silk_reward', r.silk_reward,
            'is_boss_room', r.is_boss_room,
            'word', ve.word,
            'word_id', ve.id,
            'map_id', f.map_id,
            'unlocked', CASE WHEN uru.id IS NOT NULL THEN true ELSE false END,
            'completed', CASE WHEN uru.completed_at IS NOT NULL THEN true ELSE false END
          ) ORDER BY r.room_number
        ) as rooms
      FROM floors f
      LEFT JOIN rooms r ON f.id = r.floor_id
      LEFT JOIN vocab_entries ve ON r.word_id = ve.id
      LEFT JOIN user_room_unlocks uru ON r.id = uru.room_id AND uru.user_id = $2
      WHERE f.map_id = $1
      GROUP BY f.id
      ORDER BY f.floor_number
    `, [mapId, userId]);
    
    // Get user's progress on this map
    const { rows: progressRows } = await pool.query(
      'SELECT * FROM user_map_progress WHERE user_id = $1 AND map_id = $2',
      [userId, mapId]
    );
    
    const progress = progressRows.length > 0 ? progressRows[0] : {
      current_floor: 1,
      current_room: 1,
      floors_completed: 0,
      total_silk_spent: 0,
      total_silk_earned: 0
    };
    
    res.json({
      ...map,
      floors,
      progress
    });
  } catch (error) {
    console.error('Error fetching map details:', error);
    res.status(500).json({ error: 'Failed to fetch map details' });
  }
});

// Unlock a room
router.post('/:mapId/rooms/:roomId/unlock', authenticateToken, async (req, res) => {
  try {
    const { mapId, roomId } = req.params;
    const userId = req.user.userId;
    console.log('🔓 Unlocking room:', roomId, 'for user:', userId, 'map:', mapId);
    
    // Get room details
    const { rows: roomRows } = await pool.query(`
      SELECT r.*, ve.word, u.silk_balance
      FROM rooms r
      JOIN vocab_entries ve ON r.word_id = ve.id
      JOIN users u ON u.id = $1
      WHERE r.id = $2
    `, [userId, roomId]);
    
    if (roomRows.length === 0) {
      return res.status(404).json({ error: 'Room not found' });
    }
    
    const room = roomRows[0];
    
    // Check if user has enough Silk
    if (room.silk_balance < room.silk_cost) {
      return res.status(400).json({ error: 'Insufficient Silk to unlock this room' });
    }
    
    // Check if room is already unlocked
    const { rows: unlockRows } = await pool.query(
      'SELECT * FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
      [userId, roomId]
    );
    
    if (unlockRows.length > 0) {
      return res.status(400).json({ error: 'Room is already unlocked' });
    }
    
    // Deduct Silk and unlock room
    await pool.query('BEGIN');
    
    try {
      // Deduct Silk
      await pool.query(
        'UPDATE users SET silk_balance = silk_balance - $1 WHERE id = $2',
        [room.silk_cost, userId]
      );
      
      // Unlock room
      await pool.query(
        'INSERT INTO user_room_unlocks (user_id, room_id, silk_spent) VALUES ($1, $2, $3)',
        [userId, roomId, room.silk_cost]
      );
      
      // Update user progress
      await pool.query(`
        INSERT INTO user_map_progress (user_id, map_id, total_silk_spent)
        VALUES ($1, $2, $3)
        ON CONFLICT (user_id, map_id)
        DO UPDATE SET 
          total_silk_spent = user_map_progress.total_silk_spent + $3,
          updated_at = NOW()
      `, [userId, mapId, room.silk_cost]);
      
      await pool.query('COMMIT');
      
      res.json({ 
        success: true, 
        message: `Room unlocked! You spent ${room.silk_cost} Silk.`,
        newSilkBalance: room.silk_balance - room.silk_cost
      });
    } catch (error) {
      await pool.query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    console.error('❌ Error unlocking room:', error);
    console.error('Error details:', error.message, error.stack);
    res.status(500).json({ error: `Failed to unlock room: ${error.message}` });
  }
});

// Complete a room (earn Silk reward)
router.post('/:mapId/rooms/:roomId/complete', authenticateToken, async (req, res) => {
  try {
    const { mapId, roomId } = req.params;
    const userId = req.user.userId;
    
    // Get room details
    const { rows: roomRows } = await pool.query(`
      SELECT r.*, ve.word, us.silk_balance
      FROM rooms r
      JOIN vocab_entries ve ON r.word_id = ve.id
      JOIN user_stats us ON us.user_id = $1
      WHERE r.id = $2
    `, [userId, roomId]);
    
    if (roomRows.length === 0) {
      return res.status(404).json({ error: 'Room not found' });
    }
    
    const room = roomRows[0];
    
    // Check if room is unlocked
    const { rows: unlockRows } = await pool.query(
      'SELECT * FROM user_room_unlocks WHERE user_id = $1 AND room_id = $2',
      [userId, roomId]
    );
    
    if (unlockRows.length === 0) {
      return res.status(400).json({ error: 'Room must be unlocked first' });
    }
    
    if (unlockRows[0].completed_at) {
      return res.status(400).json({ error: 'Room is already completed' });
    }
    
    // Award Silk and mark room as completed
    await pool.query('BEGIN');
    
    try {
      // Award Silk
      await pool.query(
        'UPDATE user_stats SET silk_balance = silk_balance + $1 WHERE user_id = $2',
        [room.silk_reward, userId]
      );
      
      // Mark room as completed
      await pool.query(
        'UPDATE user_room_unlocks SET completed_at = NOW(), silk_earned = $1 WHERE user_id = $2 AND room_id = $3',
        [room.silk_reward, userId, roomId]
      );
      
      // Update user progress
      await pool.query(`
        INSERT INTO user_map_progress (user_id, map_id, total_silk_earned)
        VALUES ($1, $2, $3)
        ON CONFLICT (user_id, map_id)
        DO UPDATE SET 
          total_silk_earned = user_map_progress.total_silk_earned + $3,
          updated_at = NOW()
      `, [userId, mapId, room.silk_reward]);
      
      await pool.query('COMMIT');
      
      res.json({ 
        success: true, 
        message: `Room completed! You earned ${room.silk_reward} Silk.`,
        newSilkBalance: room.silk_balance + room.silk_reward
      });
    } catch (error) {
      await pool.query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    console.error('Error completing room:', error);
    res.status(500).json({ error: 'Failed to complete room' });
  }
});

// Start floor boss challenge
router.post('/:mapId/floors/:floorId/boss/start', authenticateToken, async (req, res) => {
  try {
    const { mapId, floorId } = req.params;
    const userId = req.user.userId;
    
    // Get floor boss scenarios
    const { rows: scenarioRows } = await pool.query(`
      SELECT fbs.*, ve.word
      FROM floor_boss_scenarios fbs
      JOIN vocab_entries ve ON fbs.correct_word_id = ve.id
      WHERE fbs.floor_id = $1
      ORDER BY RANDOM()
    `, [floorId]);
    
    if (scenarioRows.length === 0) {
      return res.status(404).json({ error: 'No boss scenarios found for this floor' });
    }
    
    // Create boss attempt record
    const { rows: attemptRows } = await pool.query(
      'INSERT INTO user_floor_boss_attempts (user_id, floor_id, total_scenarios) VALUES ($1, $2, $3) RETURNING id',
      [userId, floorId, scenarioRows.length]
    );
    
    const attemptId = attemptRows[0].id;
    
    // Return scenarios without the correct answers
    const scenarios = scenarioRows.map(scenario => ({
      id: scenario.id,
      scenario_text: scenario.scenario_text,
      difficulty_level: scenario.difficulty_level
    }));
    
    res.json({
      attemptId,
      scenarios,
      totalScenarios: scenarioRows.length
    });
  } catch (error) {
    console.error('Error starting floor boss challenge:', error);
    res.status(500).json({ error: 'Failed to start floor boss challenge' });
  }
});

// Complete floor boss challenge
router.post('/:mapId/floors/:floorId/boss/complete', authenticateToken, async (req, res) => {
  try {
    const { mapId, floorId } = req.params;
    const { attemptId, responses } = req.body;
    const userId = req.user.userId;
    
    // Get the attempt record
    const { rows: attemptRows } = await pool.query(
      'SELECT * FROM user_floor_boss_attempts WHERE id = $1 AND user_id = $2 AND floor_id = $3',
      [attemptId, userId, floorId]
    );
    
    if (attemptRows.length === 0) {
      return res.status(404).json({ error: 'Boss attempt not found' });
    }
    
    const attempt = attemptRows[0];
    
    if (attempt.completed_at) {
      return res.status(400).json({ error: 'Boss challenge already completed' });
    }
    
    // Get the correct answers
    const { rows: scenarioRows } = await pool.query(`
      SELECT fbs.*, ve.word
      FROM floor_boss_scenarios fbs
      JOIN vocab_entries ve ON fbs.correct_word_id = ve.id
      WHERE fbs.floor_id = $1
    `, [floorId]);
    
    // Check responses
    let correctCount = 0;
    const results = [];
    
    for (const response of responses) {
      const scenario = scenarioRows.find(s => s.id === response.scenarioId);
      if (scenario && response.word.toLowerCase() === scenario.word.toLowerCase()) {
        correctCount++;
        results.push({ scenarioId: response.scenarioId, correct: true });
      } else {
        results.push({ 
          scenarioId: response.scenarioId, 
          correct: false, 
          correctWord: scenario?.word 
        });
      }
    }
    
    const success = correctCount === scenarioRows.length;
    const silkEarned = success ? 100 : 0; // Floor completion bonus
    
    // Update attempt record
    await pool.query('BEGIN');
    
    try {
      await pool.query(
        'UPDATE user_floor_boss_attempts SET scenarios_presented = $1, user_responses = $2, correct_count = $3, success = $4, silk_earned = $5, completed_at = NOW() WHERE id = $6',
        [JSON.stringify(scenarioRows.map(s => s.id)), JSON.stringify(responses), correctCount, success, silkEarned, attemptId]
      );
      
      if (success) {
        // Award Silk for floor completion
        await pool.query(
          'UPDATE user_stats SET silk_balance = silk_balance + $1 WHERE user_id = $2',
          [silkEarned, userId]
        );
        
        // Update user progress to next floor
        await pool.query(`
          INSERT INTO user_map_progress (user_id, map_id, current_floor, floors_completed, total_silk_earned)
          VALUES ($1, $2, $3, 1, $4)
          ON CONFLICT (user_id, map_id)
          DO UPDATE SET 
            current_floor = user_map_progress.current_floor + 1,
            floors_completed = user_map_progress.floors_completed + 1,
            total_silk_earned = user_map_progress.total_silk_earned + $4,
            updated_at = NOW()
        `, [userId, mapId, parseInt(floorId) + 1, silkEarned]);
      }
      
      await pool.query('COMMIT');
      
      res.json({
        success,
        correctCount,
        totalScenarios: scenarioRows.length,
        results,
        silkEarned,
        message: success ? 
          `Floor completed! You earned ${silkEarned} Silk and unlocked the next floor!` :
          `Floor challenge failed. You got ${correctCount}/${scenarioRows.length} correct. Try again!`
      });
    } catch (error) {
      await pool.query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    console.error('Error completing floor boss challenge:', error);
    res.status(500).json({ error: 'Failed to complete floor boss challenge' });
  }
});

// Complete guardian challenge and unlock next floor
router.post('/unlock-next-floor', authenticateToken, async (req, res) => {
  try {
    const { currentFloor } = req.body;
    const userId = req.user.userId;
    
    console.log('🔓 Unlock next floor request:', { currentFloor, userId });
    
    // Find the next floor
    const { rows: nextFloorRows } = await pool.query(`
      SELECT f.* FROM floors f
      WHERE f.floor_number = $1
      LIMIT 1
    `, [currentFloor + 1]);
    
    if (nextFloorRows.length === 0) {
      return res.status(404).json({ error: 'Next floor not found' });
    }
    
    const nextFloor = nextFloorRows[0];
    console.log('✓ Found next floor:', nextFloor.name);
    
    // Update user progress to next floor
    await pool.query(`
      INSERT INTO user_map_progress (user_id, map_id, current_floor)
      VALUES ($1, $2, $3)
      ON CONFLICT (user_id, map_id)
      DO UPDATE SET current_floor = $3, updated_at = NOW()
    `, [userId, nextFloor.map_id, currentFloor + 1]);
    
    console.log('✅ User progress updated to floor', currentFloor + 1);
    
    res.json({ 
      success: true, 
      message: `Floor ${currentFloor + 1} unlocked!`,
      nextFloor: {
        id: nextFloor.id,
        floor_number: nextFloor.floor_number,
        name: nextFloor.name
      }
    });
  } catch (error) {
    console.error('Error unlocking next floor:', error);
    res.status(500).json({ error: 'Failed to unlock next floor' });
  }
});

export default router;
