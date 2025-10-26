import express from 'express';
import { pool } from '../db/index.js';

const router = express.Router();

// GET /api/meta/tags - List all causal tags
router.get('/tags', async (req, res) => {
  try {
    const query = `
      SELECT DISTINCT ct.tag_name, ct.description, COUNT(tet.event_id) as usage_count
      FROM causal_tags ct
      LEFT JOIN timeline_event_tags tet ON ct.id = tet.tag_id
      GROUP BY ct.id, ct.tag_name, ct.description
      ORDER BY ct.tag_name ASC
    `;
    
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/meta/centuries - List all centuries with word counts
router.get('/centuries', async (req, res) => {
  try {
    const query = `
      SELECT DISTINCT century, COUNT(DISTINCT vocab_id) as word_count
      FROM word_timeline_events
      WHERE century IS NOT NULL
      GROUP BY century
      ORDER BY century ASC
    `;
    
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;

