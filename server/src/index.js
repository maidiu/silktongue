import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import vocabRoutes from './routes/vocab.js';
import exploreRoutes from './routes/explore.js';
import metaRoutes from './routes/meta.js';
import quizRoutes from './routes/quiz.js';
import authRoutes from './routes/auth.js';
import mapsRoutes from './routes/maps.js';
import cron from 'node-cron';
import { pool } from './db/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());

// API routes - support both /api and /silktongue/api
app.use('/silktongue/api/vocab', vocabRoutes);
app.use('/silktongue/api/explore', exploreRoutes);
app.use('/silktongue/api/meta', metaRoutes);
app.use('/silktongue/api/quiz', quizRoutes);
app.use('/silktongue/api/auth', authRoutes);
app.use('/silktongue/api/maps', mapsRoutes);

app.use('/api/vocab', vocabRoutes);
app.use('/api/explore', exploreRoutes);
app.use('/api/meta', metaRoutes);
app.use('/api/quiz', quizRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/maps', mapsRoutes);

// Serve static files from React build in production
const clientBuildPath = path.join(__dirname, '../../client/dist');

// Serve static files at root and /silktongue
app.use(express.static(clientBuildPath));
app.use('/silktongue', express.static(clientBuildPath));

// Serve React app for all non-API routes
app.get('*', (req, res, next) => {
  // Skip API routes
  if (req.path.startsWith('/api') || req.path.startsWith('/silktongue/api')) {
    return next();
  }
  res.sendFile(path.join(clientBuildPath, 'index.html'));
});

cron.schedule('0 0 * * *', async () => {
  console.log('[CRON] Resetting user health...');
  await pool.query(`
    UPDATE users
    SET health_points = 5,
        last_health_reset = NOW()
    WHERE last_health_reset < NOW() - INTERVAL '1 day';
  `);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
