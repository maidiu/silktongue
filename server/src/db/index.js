import pg from 'pg';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env from the project root (two levels up from src/db/)
dotenv.config({ path: path.resolve(__dirname, '../../../.env') });

const { Pool } = pg;
export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});
