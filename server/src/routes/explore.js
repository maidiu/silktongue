import express from 'express';
import { pool } from '../db/index.js';

const router = express.Router();

// GET /api/explore - Filter by century and/or tags
router.get('/', async (req, res) => {
  try {
    const { century, tag } = req.query;
    
    let query = `
      SELECT DISTINCT 
        ve.id, ve.word, ve.part_of_speech, ve.modern_definition, 
        ve.usage_example, ve.is_mastered, ve.date_added
      FROM vocab_entries ve
      JOIN word_timeline_events wte ON ve.id = wte.vocab_id
    `;
    
    const conditions = [];
    const params = [];
    let paramCount = 1;
    
    if (century) {
      conditions.push(`wte.century = $${paramCount}`);
      params.push(century);
      paramCount++;
    }
    
    if (tag) {
      query += `
        JOIN timeline_event_tags tet ON wte.id = tet.event_id
        JOIN causal_tags ct ON tet.tag_id = ct.id
      `;
      conditions.push(`ct.tag_name = $${paramCount}`);
      params.push(tag);
      paramCount++;
    }
    
    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }
    
    query += ' ORDER BY ve.word ASC';
    
    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;

