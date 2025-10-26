# 🚀 MaxVocab - Quick Start Guide

## What You Have Now

A complete historical-semantic vocabulary platform with:
- Rich timeline tracking across centuries
- Causal analysis tags (theological_moralization, printing_revolution, etc.)
- Word relation networks (synonyms, antonyms, roots)
- Cross-linguistic equivalents
- Full-text search and exploration by century/tag

---

## Running the System

### 1. Start the Backend (Terminal 1)
```bash
cd server
npm run dev
# Server will run on http://localhost:3000
```

### 2. Start the Frontend (Terminal 2)
```bash
cd client
npm run dev
# Frontend will run on http://localhost:5173
```

### 3. Open Browser
Navigate to: **http://localhost:5173**

---

## Adding New Vocabulary

### Step 1: Create a JSON Entry

Create a file in `weekly_entries/` (e.g., `2025-10-20.json`) using this structure:

```json
[
  {
    "word": "suppress",
    "part_of_speech": "verb",
    "modern_definition": "To forcibly prevent or put an end to something",
    "usage_example": "The government tried to suppress the protests.",
    "synonyms": ["repress", "quell", "stifle"],
    "antonyms": ["encourage", "promote", "express"],
    "related": ["suppression", "repression"],
    "french_equivalent": "supprimer / réprimer",
    "russian_equivalent": "подавлять (podavlyat')",
    "cefr_level": "C1",
    "structural_analysis": "Your synthesis of semantic forces here...",
    "timeline": [
      {
        "century": 14,
        "exact_date": "c. 1340",
        "language_stage": "Middle English",
        "region": "England",
        "semantic_focus": "legal",
        "event_text": "Narrative about the word's meaning at this time...",
        "sibling_words": ["press", "oppress"],
        "context": "Cultural/historical context...",
        "causal_tags": ["legal_formalization", "language_transition"]
      }
    ],
    "roots": [
      {
        "root_word": "premere",
        "language": "Latin",
        "gloss": "to press down",
        "relation_description": "via sub- + premere"
      }
    ],
    "domains": ["legal", "political", "psychological"]
  }
]
```

**See `weekly_entries/sample_omission.json` for a complete example!**

### Step 2: Run Ingestion

```bash
cd server
node scripts/ingest_vocab_enhanced.js ../weekly_entries/2025-10-20.json
```

You'll see:
```
📚 Ingesting 1 vocabulary entry...
  Processing: suppress
    ✓ Inserted/updated suppress with 1 timeline events
✅ Successfully ingested 1 entry
```

### Step 3: Refresh Browser

New words appear immediately—no rebuild needed!

---

## Exploring Your Data

### Homepage (Browse)
- Lists all words with sort/filter
- Click "Show History" on any word to expand timeline
- Toggle "learned" status with checkmark button

### Explorer Page
- Filter by **century**: "Show me 14th century words"
- Filter by **tag**: "Show me words affected by printing_revolution"
- Combine filters: "14th century + theological_moralization"

### Search
- Type in the search bar (top right)
- Searches across: word, definition, timeline text
- Real-time results dropdown

---

## JSON Spec Reference

**Full specification:** `docs/schema/vocab_entry_schema_v2.json`

### Required Fields
```json
{
  "word": "string (required)",
  "part_of_speech": "string (required)",
  "modern_definition": "string (required)",
  "usage_example": "string (required)",
  "french_equivalent": "string (required)",
  "russian_equivalent": "string (required)",
  "structural_analysis": "string (required)"
}
```

### Optional Rich Data
```json
{
  "synonyms": ["array of strings"],
  "antonyms": ["array of strings"],
  "related": ["array of strings"],
  "common_collocations": ["array of strings"],
  "cefr_level": "A1 | A2 | B1 | B2 | C1 | C2",
  "pronunciation": "IPA string",
  "story_text": "quick summary for display",
  "contrastive_opening": "pedagogical intro",
  "metadata": { "flexible": "JSON object" }
}
```

### Timeline Events
```json
{
  "timeline": [
    {
      "century": 14,                    // Required: integer
      "exact_date": "c. 1340",          // Optional: human-readable
      "language_stage": "Middle English",
      "region": "England",
      "semantic_focus": "legal",        // Domain tag
      "event_text": "The narrative...",  // Required
      "sibling_words": ["related", "words"],
      "context": "Cultural context...",
      "causal_tags": ["tag1", "tag2"],
      "citations": [
        {
          "source": "OED, 3rd edition",
          "url": "https://...",
          "quote": "Optional excerpt"
        }
      ]
    }
  ]
}
```

### Root Families
```json
{
  "roots": [
    {
      "root_word": "mittere",
      "language": "Latin",
      "gloss": "to send",
      "relation_description": "Direct descendant"
    }
  ]
}
```

### Semantic Domains
```json
{
  "domains": ["legal", "moral", "editorial"]
}
```

### Derivations
```json
{
  "derivations": [
    {
      "related_word": "omit",
      "relation_type": "derives_from",  // or: compound_of, borrowed_via, etc.
      "direction": "parent",            // or: child
      "notes": "Verb form"
    }
  ]
}
```

---

## Common Causal Tags

Use these (or create your own):
- `theological_moralization` - Religious influence on meaning
- `printing_revolution` - Impact of print technology
- `bureaucratic_expansion` - Administrative contexts
- `lexical_competition` - Competition within word families
- `legal_formalization` - Legal/technical contexts
- `scientific_standardization` - Scientific register development
- `language_transition` - Old French → Middle English, etc.
- `editorial_professionalization` - Textual/rhetorical contexts
- `semantic_neutralization` - Loss of moral/emotional connotations
- `category_expansion` - Broadening of meaning
- `category_refinement` - Narrowing/specialization

---

## API Endpoints (for custom tools)

### Vocabulary
```bash
GET /api/vocab                    # List all words
GET /api/vocab/:id                # Get single word with full data
GET /api/vocab/search?q=term      # Search
PATCH /api/vocab/:id/learned      # Toggle learned status
```

### Exploration
```bash
GET /api/explore?century=14              # Filter by century
GET /api/explore?tag=printing_revolution # Filter by tag
GET /api/explore?century=14&tag=moral    # Combined filter
```

### Metadata
```bash
GET /api/meta/centuries           # List centuries with word counts
GET /api/meta/tags                # List causal tags with usage counts
```

---

## Database Access (if needed)

```bash
# Connect to database
psql -U postgres -d vocab_atlas

# List all words
SELECT word, modern_definition FROM vocab_entries;

# View timeline for a word
SELECT century, event_text 
FROM word_timeline_events 
WHERE vocab_id = 1 
ORDER BY century;

# View all causal tags
SELECT tag_name, COUNT(*) 
FROM causal_tags ct
JOIN timeline_event_tags tet ON ct.id = tet.tag_id
GROUP BY tag_name;
```

---

## Troubleshooting

### "Server not running"
```bash
cd server
npm run dev
```
Check: http://localhost:3000/api/vocab

### "Frontend not loading"
```bash
cd client
npm run dev
```
Check: http://localhost:5173

### "Ingestion failed"
- Check JSON syntax (use JSONLint.com)
- Ensure required fields are present
- Check server/.env has DATABASE_URL

### "Word not appearing"
- Refresh browser (Cmd+R or Ctrl+R)
- Check ingestion output for errors
- Verify with: `curl http://localhost:3000/api/vocab`

---

## Tips & Best Practices

1. **Timeline Events**: Aim for 3-6 key moments across centuries
2. **Causal Tags**: Use 1-3 tags per event (most important forces)
3. **Structural Analysis**: Write this LAST—synthesize your timeline
4. **Bidirectional Synonyms**: Will be created automatically
5. **Stub Entries**: Referenced words get auto-created (fill in later)
6. **Idempotent Ingestion**: Safe to run same file multiple times

---

## Example Workflow

**Monday:** Research "suppress" word history  
**Tuesday:** Draft JSON entry with timeline  
**Wednesday:** Add citations and refinements  
**Thursday:** Run ingestion: `node scripts/ingest_vocab_enhanced.js ...`  
**Friday:** Assign to students via frontend  
**Weekend:** Students explore and mark as learned

---

## Getting Help

- **JSON Spec**: `docs/schema/vocab_entry_schema_v2.json`
- **Sample Entry**: `weekly_entries/sample_omission.json`
- **Implementation Details**: `IMPLEMENTATION_COMPLETE.md`
- **Gap Analysis**: `ACTUAL_GAP_ANALYSIS.md`

---

**Happy Vocab Building! 📚✨**
