# Getting Started with Vocabulary Atlas

This guide will help you set up and run the Vocabulary Atlas application.

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v14 or higher)
- npm or yarn

## Setup Instructions

### 1. Database Setup

First, create a PostgreSQL database:

```bash
# Connect to PostgreSQL
psql -U postgres

# Create the database
CREATE DATABASE vocab_atlas;

# Exit psql
\q
```

### 2. Run Database Migrations

Apply the SQL schema files:

```bash
# Run the initialization script
psql -U postgres -d vocab_atlas -f server/sql/001_init.sql

# Run the vocab schema
psql -U postgres -d vocab_atlas -f server/sql/002_vocab_schema.sql
```

### 3. Environment Variables

Create a `.env` file in the `server/` directory:

```bash
cd server
cp .env.example .env
```

Edit `server/.env` and update with your database credentials:

```
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/vocab_atlas
PORT=3000
```

### 4. Install Dependencies

Install dependencies for both client and server:

```bash
# From the root directory
npm install

# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

### 5. Run the Application

#### Development Mode

From the root directory, run both client and server concurrently:

```bash
npm run dev
```

This will start:
- **Client** on `http://localhost:5173` (Vite dev server)
- **Server** on `http://localhost:3000` (Express API)

The Vite dev server proxies API requests to the Express server automatically.

#### Production Mode

Build and run for production:

```bash
# Build the client
cd client
npm run build

# This creates a dist/ folder with the production build
# The Express server serves this automatically

# Start the server
cd ../server
npm start
```

The server will serve both the API and the React app on `http://localhost:3000`.

## API Endpoints

The application provides the following API endpoints:

### Vocabulary
- `GET /api/vocab` - List all vocabulary words (with sorting and filtering)
- `GET /api/vocab/:id` - Get a single word with full timeline
- `GET /api/vocab/search?q=query` - Search words
- `PATCH /api/vocab/:id/learned` - Toggle learned status

### Explorer
- `GET /api/explore?century=12&tag=printing_revolution` - Filter by century/tag

### Metadata
- `GET /api/meta/tags` - List all causal tags
- `GET /api/meta/centuries` - List all centuries

## Features

### Student Mode (Homepage)
- Browse vocabulary by date added or alphabetically
- Search words in real-time
- Filter by learned/unlearned status
- Mark words as learned
- Expand cards to view historical narratives

### Explorer Mode
- Filter words by century (e.g., 12th century)
- Filter by causal tags (e.g., printing_revolution, moralization)
- Discover thematic patterns across the vocabulary

### Word Detail View
- Deep link to individual words
- Full historical timeline with dated narrative blocks
- Related words (synonyms, antonyms, root family)
- Etymology and structural analysis

## Project Structure

```
MaxVocab/
├── client/              # React frontend (Vite + TypeScript)
│   ├── src/
│   │   ├── api/         # API client functions
│   │   ├── components/  # React components
│   │   ├── hooks/       # Custom React hooks
│   │   ├── pages/       # Page components
│   │   └── App.tsx      # Main app with routing
│   └── package.json
│
├── server/              # Express backend
│   ├── src/
│   │   ├── db/          # Database connection
│   │   ├── routes/      # API routes
│   │   └── index.js     # Server entry point
│   ├── sql/             # Database schema
│   └── package.json
│
└── package.json         # Root package (dev scripts)
```

## Adding Vocabulary Data

To add vocabulary entries, you can:

1. **Insert directly via SQL:**
   ```sql
   INSERT INTO vocab_entries (word, part_of_speech, modern_definition, usage_example, is_mastered)
   VALUES ('example', 'noun', 'A thing characteristic of its kind', 'This is an example sentence', false);
   ```

2. **Use the database schema** defined in `server/sql/002_vocab_schema.sql` to add:
   - Timeline events
   - Word relations (synonyms, antonyms)
   - Root families
   - Causal tags

## Troubleshooting

### Database Connection Issues
- Verify PostgreSQL is running: `pg_isready`
- Check your DATABASE_URL in `server/.env`
- Ensure the database exists: `psql -l`

### Port Conflicts
- If port 3000 or 5173 is in use, update:
  - Server port in `server/.env`
  - Vite dev server in `client/vite.config.ts`

### Build Errors
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Check Node.js version: `node --version` (should be v18+)

## Next Steps

1. Add vocabulary entries to the database
2. Explore the student interface at `http://localhost:5173`
3. Try the Explorer mode to filter by century or causal tags
4. Customize the UI styling in the Tailwind config

## Documentation

For more details about the project architecture and design decisions, see:
- `server/README_FOR_CURSOR.md` - Complete project specification
- `server/sql/002_vocab_schema.sql` - Database schema with comments

Enjoy building your vocabulary atlas! 📚

