# 🧭 Vocabulary Atlas

A historical-semantic vocabulary platform that treats each word not just as a definition, but as a **narrative entity across time**.

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 📖 Overview

Vocabulary Atlas is a full-stack web application designed for students and language enthusiasts who want to understand not just what words mean, but **how** and **why** their meanings evolved across history.

### Key Features

- 📚 **Student Mode**: Browse vocabulary with modern definitions, usage examples, and translations
- 🕰️ **Historical Timeline**: Expand any word to see its semantic evolution through dated narrative blocks
- 🔍 **Smart Search**: Real-time search across words, definitions, and historical narratives
- 🗺️ **Explorer Mode**: Filter words by century or causal patterns (printing revolution, moralization, etc.)
- ✅ **Progress Tracking**: Mark words as learned and filter your vocabulary
- 🌐 **Multilingual**: Includes French and Russian equivalents

## 🏗️ Architecture

### Tech Stack

**Frontend:**
- React 19 with TypeScript
- Vite for fast development
- React Router for navigation
- Tailwind CSS for styling

**Backend:**
- Node.js + Express
- PostgreSQL database
- RESTful API design

**Database:**
- Rich relational schema supporting:
  - Vocabulary entries with full lexical data
  - Historical timeline events with dating
  - Word relations (synonyms, antonyms, related)
  - Root families and etymological links
  - Causal tags for semantic shift patterns
  - Full-text search capabilities

## 🚀 Quick Start

### Prerequisites

- Node.js v18+
- PostgreSQL v14+
- npm or yarn

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd MaxVocab
   ```

2. **Set up the database:**
   ```bash
   # Create database
   createdb vocab_atlas
   
   # Run migrations
   psql -d vocab_atlas -f server/sql/001_init.sql
   psql -d vocab_atlas -f server/sql/002_vocab_schema.sql
   
   # (Optional) Load sample data
   psql -d vocab_atlas -f server/sql/003_sample_data.sql
   ```

3. **Configure environment variables:**
   ```bash
   cd server
   echo "DATABASE_URL=postgresql://localhost/vocab_atlas" > .env
   echo "PORT=3000" >> .env
   cd ..
   ```

4. **Install dependencies:**
   ```bash
   # Root dependencies
   npm install
   
   # Server dependencies
   cd server && npm install && cd ..
   
   # Client dependencies
   cd client && npm install && cd ..
   ```

5. **Start the development servers:**
   ```bash
   npm run dev
   ```

   This starts:
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3000

## 📚 Documentation

- **[Getting Started Guide](./GETTING_STARTED.md)** - Detailed setup and usage instructions
- **[Architecture Overview](./server/README_FOR_CURSOR.md)** - Complete project specification
- **[Database Schema](./server/sql/002_vocab_schema.sql)** - Schema documentation with comments

## 🎯 Use Cases

### For Students
- **Deep Learning**: Understand words not just as definitions, but as evolving concepts
- **Pattern Recognition**: See how historical forces (printing, moralization, etc.) shaped language
- **Active Vocabulary Building**: Track your progress with learned/unlearned filters

### For Educators
- **Teaching Tool**: Demonstrate semantic change with rich historical narratives
- **Curriculum Building**: Organize vocabulary by themes, periods, or linguistic patterns
- **Research Platform**: Build a searchable linguistic atlas over time

### For Researchers
- **Linguistic Database**: Query words by century, causal tags, or etymological roots
- **Cross-Indexing**: Navigate semantic networks through word relations
- **Trend Analysis**: Identify macro-linguistic patterns across the vocabulary

## 🗂️ Project Structure

```
MaxVocab/
├── client/                  # React frontend
│   ├── src/
│   │   ├── components/     # UI components (cards, filters, layouts)
│   │   ├── pages/          # Page components (Home, Explorer, Detail)
│   │   ├── hooks/          # Custom React hooks
│   │   ├── api/            # API client functions
│   │   └── App.tsx         # Main app with routing
│   └── package.json
│
├── server/                  # Express backend
│   ├── src/
│   │   ├── routes/         # API routes (vocab, explore, meta)
│   │   ├── db/             # Database connection
│   │   └── index.js        # Server entry point
│   ├── sql/                # Database migrations and schema
│   │   ├── 001_init.sql
│   │   ├── 002_vocab_schema.sql
│   │   └── 003_sample_data.sql
│   └── package.json
│
├── package.json            # Root package with dev scripts
├── README.md              # This file
└── GETTING_STARTED.md     # Setup guide
```

## 🔌 API Endpoints

### Vocabulary
- `GET /api/vocab` - List vocabulary (with sort/filter params)
- `GET /api/vocab/:id` - Get single word with full timeline
- `GET /api/vocab/search?q=query` - Search words
- `PATCH /api/vocab/:id/learned` - Toggle learned status

### Explorer
- `GET /api/explore?century=12&tag=moralization` - Filter by century/tag

### Metadata
- `GET /api/meta/tags` - List all causal tags
- `GET /api/meta/centuries` - List all centuries

## 🎨 UI/UX Design Principles

- **Minimalist & Uncluttered**: Clean card-based interface
- **Progressive Disclosure**: Collapsed cards with expandable historical stories
- **Fast & Responsive**: Optimistic UI updates and debounced search
- **Accessibility**: Semantic HTML, keyboard navigation, clear focus states

## 🌟 Roadmap

- [ ] User authentication and personal progress tracking
- [ ] Advanced search syntax (e.g., "12th century moralization")
- [ ] Graph visualization of word relations and root families
- [ ] Export functionality (CSV, PDF study guides)
- [ ] Mobile app (React Native)
- [ ] Community contributions (crowd-sourced etymologies)

## 🤝 Contributing

Contributions are welcome! Here are some ways to contribute:

1. **Add Vocabulary Data**: Use the schema to add richly annotated words
2. **Improve UI/UX**: Enhance components, add animations, improve accessibility
3. **Extend Features**: Implement items from the roadmap
4. **Documentation**: Improve guides, add examples, write tutorials

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Inspired by historical lexicography and semantic change research
- Built with modern web technologies for performance and developer experience
- Designed for students who want to truly understand language

---

**Happy vocabulary building!** 📚✨

For questions or support, please open an issue on GitHub.

