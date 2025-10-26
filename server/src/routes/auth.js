import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../db/index.js';

const router = express.Router();

// Register endpoint
router.post('/register', async (req, res) => {
  console.log('Register route hit!');
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Check if username already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE username = $1',
      [username]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Username already exists' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user with default values
    const newUser = await pool.query(
      `INSERT INTO users (username, password_hash, silk_balance, health_points, max_health_points, avatar_config)
       VALUES ($1, $2, 0, 3, 3, $3)
       RETURNING id, username, silk_balance, health_points, max_health_points, avatar_config`,
      [
        username,
        passwordHash,
        JSON.stringify({
          body: 'hornet',
          mask: 'hornet',
          wings: 'silk',
          weapon: 'needle',
          primaryColor: '#2d1b2d',
          secondaryColor: '#4a2c4a',
          accentColor: '#ff6b6b',
          effects: ['sparkle']
        })
      ]
    );

    const user = newUser.rows[0];

    // Create JWT token
    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username 
      },
      process.env.JWT_SECRET || 'fallback-secret-key',
      { expiresIn: '24h' }
    );

    // Return user data (without password hash)
    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        silkBalance: user.silk_balance,
        healthPoints: user.health_points,
        maxHealthPoints: user.max_health_points || 3,
        isAdmin: false,
        avatarConfig: user.avatar_config || {
          body: 'hornet',
          mask: 'hornet',
          wings: 'silk',
          weapon: 'needle',
          primaryColor: '#2d1b2d',
          secondaryColor: '#4a2c4a',
          accentColor: '#ff6b6b',
          effects: ['sparkle']
        }
      }
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login endpoint
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Find user
    const userResult = await pool.query(
      'SELECT id, username, password_hash, silk_balance, health_points, max_health_points, is_admin, avatar_config FROM users WHERE username = $1',
      [username]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = userResult.rows[0];

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Create JWT token
    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username 
      },
      process.env.JWT_SECRET || 'fallback-secret-key',
      { expiresIn: '24h' }
    );

    // Return user data (without password hash)
    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        silkBalance: user.silk_balance,
        healthPoints: user.health_points,
        maxHealthPoints: user.max_health_points || 3,
        isAdmin: user.is_admin || false,
        avatarConfig: user.avatar_config || {
          body: 'hornet',
          mask: 'hornet',
          wings: 'silk',
          weapon: 'needle',
          primaryColor: '#2d1b2d',
          secondaryColor: '#4a2c4a',
          accentColor: '#ff6b6b',
          effects: ['sparkle']
        }
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Change password endpoint
router.post('/change-password', async (req, res) => {
  try {
    const { userId, currentPassword, newPassword } = req.body;

    if (!userId || !currentPassword || !newPassword) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Get user
    const userResult = await pool.query(
      'SELECT password_hash FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];

    // Verify current password
    const isValidPassword = await bcrypt.compare(currentPassword, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Update password
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [newPasswordHash, userId]
    );

    res.json({ message: 'Password updated successfully' });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user profile
router.get('/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const userResult = await pool.query(
      'SELECT id, username, silk_balance, health_points, last_health_reset FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];
    res.json({
      id: user.id,
      username: user.username,
      silkBalance: user.silk_balance,
      healthPoints: user.health_points,
      lastHealthReset: user.last_health_reset
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Middleware to verify JWT token
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

export default router;
