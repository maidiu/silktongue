# ✅ Actual Gap Analysis - Schema vs API vs README2.md

## Your Current Database Schema (from `schema.sql`)

### ✅ What You HAVE (and it's GOOD):

#### `vocab_entries` table:
```sql
- id, word, part_of_speech, modern_definition, usage_example
- synonyms TEXT[]                    ✅ Flat array for quick display
- antonyms TEXT[]                    ✅ Flat array for quick display
- collocations JSONB                 ✅ Structured data
- french_equivalent TEXT             ✅ Correct name
- russian_equivalent TEXT            ✅ Correct name
- cefr_level TEXT                    ✅ CEFR tracking
- pronunciation TEXT                 ✅ Pronunciation
- is_mastered BOOLEAN                ✅ Learning tracking
- date_added TIMESTAMP               ✅ Chronological sorting
- story_text TEXT                    ✅ Quick story display
- contrastive_opening TEXT           ✅ Pedagogical intro
- structural_analysis TEXT           ✅ Synthesis paragraph
- common_collocations TEXT[]         ✅ Idioms array
- metadata JSONB                     ✅ Flexible extras
```

#### `word_timeline_events` table:
```sql
- id
- vocab_id INTEGER                   ✅ FK to vocab_entries
- century INTEGER                    ✅ Numeric for filtering
- exact_date TEXT                    ✅ Human-readable dates
- language_stage TEXT                ✅ "Old French", "Latin", etc.
- region TEXT                        ✅ Geographic context
- semantic_focus TEXT                ✅ Domain tags
- event_text TEXT                    ✅ Narrative paragraph
- sibling_words TEXT[]               ✅ Related words at that time
- context TEXT                       ✅ Cultural/historical context
- created_at TIMESTAMP               ✅
```

#### Relational Tables (all present):
- ✅ `word_relations` (source_id, target_id, relation_type)
- ✅ `root_families` (root_word, language, gloss)
- ✅ `word_root_links` (vocab_id, root_id)
- ✅ `semantic_domains` (name, description)
- ✅ `vocab_domain_links` (vocab_id, domain_id)
- ✅ `derivations` (parent_vocab_id, child_vocab_id, relation_type)
- ✅ `causal_tags` (tag_name, description)
- ✅ `timeline_event_tags` (event_id, tag_id)
- ✅ `citations` (event_id, source, url, quote)

#### Views & Extensions:
- ✅ `century_summary` view
- ✅ `pg_trgm` extension (trigram search)
- ✅ `btree_gin` extension

---

## 🚨 The ACTUAL Problem: API Routes Don't Match Schema

Your **schema is perfect**, but your **API routes are broken** because they query the wrong columns.

### Problem 1: `/api/vocab/:id` Timeline Query

**Current API code** (`vocab.js` lines 104-112):
```javascript
SELECT 
  century, year, sense_at_time, sibling_words,
  cultural_context, causal_tensions, language_transitions,
  event_text, sort_order
FROM word_timeline_events
WHERE vocab_entry_id = $1  // WRONG COLUMN NAME!
```

**Actual schema has:**
```sql
- century ✅
- year ❌ DOESN'T EXIST → use exact_date
- sense_at_time ❌ DOESN'T EXIST
- sibling_words ✅
- cultural_context ❌ → should be just context
- causal_tensions ❌ DOESN'T EXIST
- language_transitions ❌ DOESN'T EXIST
- event_text ❌ → should be event_text (OK, this one matches!)
- sort_order ❌ DOESN'T EXIST
- vocab_entry_id ❌ → should be vocab_id
```

### Problem 2: `/api/vocab/:id` Relations Query

**Current API** (`vocab.js` lines 129-137):
```javascript
SELECT ve.id, ve.word, ve.modern_definition, wr.relation_type
FROM word_relations wr
JOIN vocab_entries ve ON wr.related_word_id = ve.id  // WRONG COLUMN!
WHERE wr.vocab_entry_id = $1                         // WRONG COLUMN!
```

**Actual schema:**
```sql
word_relations has:
- source_id (not vocab_entry_id)
- target_id (not related_word_id)
```

### Problem 3: `/api/vocab/:id` Root Query

**Current API** (`vocab.js` lines 140-147):
```javascript
SELECT rf.root_word, rf.language, rf.meaning  // 'meaning' doesn't exist!
FROM word_root_links wrl
JOIN root_families rf ON wrl.root_id = rf.id
WHERE wrl.vocab_entry_id = $1                 // should be vocab_id
```

**Actual schema:**
```sql
root_families has:
- root_word ✅
- language ✅
- gloss (not 'meaning')

word_root_links has:
- vocab_id (not vocab_entry_id)
```

---

## ⚠️ What's MISSING (vs README2.md claims)

README2.md says these features exist, but they actually **don't**:

### Missing from `word_timeline_events`:
- ❌ `century_int` (generated numeric column) - README2 says it exists
- ❌ `centuries[]` (array for multi-century spans) - README2 says it exists

**Impact:** Can't do numeric century filtering like "WHERE century_int BETWEEN 12 AND 15"

**Note:** Your schema uses `century INTEGER` directly, which is actually BETTER than having both `century TEXT` and `century_int`. But README2.md describes a different approach.

---

## 🛠️ What Needs to Be Built

### **PRIORITY 1: Fix API Routes** (30 minutes - CRITICAL)

Fix these 3 files to match your actual schema:

#### 1. **`server/src/routes/vocab.js`** - Main vocabulary API

**Lines 104-112** - Timeline query:
```javascript
// REPLACE THIS:
const timelineQuery = `
  SELECT 
    id, century, year, sense_at_time, sibling_words,
    cultural_context, causal_tensions, language_transitions,
    event_text, sort_order
  FROM word_timeline_events
  WHERE vocab_entry_id = $1
  ORDER BY sort_order ASC, century ASC, year ASC
`;

// WITH THIS:
const timelineQuery = `
  SELECT 
    id, century, exact_date, language_stage, region,
    semantic_focus, event_text, sibling_words, context, created_at
  FROM word_timeline_events
  WHERE vocab_id = $1
  ORDER BY century ASC, exact_date ASC
`;
```

**Lines 129-137** - Relations query:
```javascript
// REPLACE THIS:
const relationsQuery = `
  SELECT ve.id, ve.word, ve.modern_definition, wr.relation_type
  FROM word_relations wr
  JOIN vocab_entries ve ON wr.related_word_id = ve.id
  WHERE wr.vocab_entry_id = $1
`;

// WITH THIS:
const relationsQuery = `
  SELECT ve.id, ve.word, ve.modern_definition, wr.relation_type
  FROM word_relations wr
  JOIN vocab_entries ve ON wr.target_id = ve.id
  WHERE wr.source_id = $1
`;
```

**Lines 140-147** - Root query:
```javascript
// REPLACE THIS:
const rootQuery = `
  SELECT rf.root_word, rf.language, rf.meaning
  FROM word_root_links wrl
  JOIN root_families rf ON wrl.root_id = rf.id
  WHERE wrl.vocab_entry_id = $1
`;

// WITH THIS:
const rootQuery = `
  SELECT rf.root_word, rf.language, rf.gloss
  FROM word_root_links wrl
  JOIN root_families rf ON wrl.root_id = rf.id
  WHERE wrl.vocab_id = $1
`;
```

#### 2. **Add Missing Queries** to `/api/vocab/:id`

Your schema has these tables, but the API doesn't query them:

```javascript
// Add after rootQuery:

// Get semantic domains
const domainsQuery = `
  SELECT sd.name, sd.description
  FROM vocab_domain_links vdl
  JOIN semantic_domains sd ON vdl.domain_id = sd.id
  WHERE vdl.vocab_id = $1
`;

// Get derivations (parent/child morphology)
const derivationsQuery = `
  SELECT 
    ve.word AS related_word,
    d.relation_type,
    d.notes,
    'parent' AS direction
  FROM derivations d
  JOIN vocab_entries ve ON d.parent_vocab_id = ve.id
  WHERE d.child_vocab_id = $1
  
  UNION ALL
  
  SELECT 
    ve.word AS related_word,
    d.relation_type,
    d.notes,
    'child' AS direction
  FROM derivations d
  JOIN vocab_entries ve ON d.child_vocab_id = ve.id
  WHERE d.parent_vocab_id = $1
`;
```

---

### **PRIORITY 2: Enhance Ingestion Script** (1-2 hours)

Your current `ingest_vocab.js` only handles basic fields. Enhance it to support:

1. **Timeline events with full metadata:**
   ```javascript
   // Currently inserts: vocab_entry_id, century, story_text
   // Should insert: vocab_id, century, exact_date, language_stage, 
   //                region, semantic_focus, event_text, sibling_words, context
   ```

2. **Root family linking:**
   ```javascript
   // Parse "root_family" from JSON
   // Insert into root_families if not exists
   // Create word_root_links entry
   ```

3. **Semantic domain tagging:**
   ```javascript
   // Parse "domains" array from JSON
   // Insert into semantic_domains if not exists
   // Create vocab_domain_links entries
   ```

4. **Derivations:**
   ```javascript
   // Parse "derived_from" or "derived_forms" from JSON
   // Create derivations entries
   ```

5. **Citations:**
   ```javascript
   // Parse "citations" array from timeline events in JSON
   // Insert into citations table linked to event_id
   ```

---

### **PRIORITY 3: Update JSON Spec & Create Sample Entry** (30 minutes)

Update `docs/schema/vocab_entry_schema.json` to match your **actual schema**, then create a sample JSON entry to test the enhanced ingestion.

---

### **PRIORITY 4: Optional Enhancements** (if you want them)

These are in README2.md but not actually needed if your current approach works:

1. **Add generated columns to `word_timeline_events`?**
   ```sql
   ALTER TABLE word_timeline_events 
   ADD COLUMN century_text TEXT GENERATED ALWAYS AS (century::text) STORED;
   
   -- For multi-century spans (if you want that feature)
   ```

2. **Add GIN search indexes?** (if search is slow)
   ```sql
   CREATE INDEX idx_vocab_search 
   ON vocab_entries USING GIN(to_tsvector('english', 
     coalesce(word,'') || ' ' || coalesce(modern_definition,'')));
   ```

---

## 📊 Summary

| Component | Status | Action |
|-----------|--------|--------|
| **Database Schema** | ✅ **COMPLETE & CORRECT** | None needed |
| **API `/api/meta/*`** | ✅ Working | None |
| **API `/api/explore`** | ⚠️ Needs testing | Verify century filtering works |
| **API `/api/vocab/:id`** | 🚨 **BROKEN** | Fix column names (30 min) |
| **Ingestion Script** | ⚠️ Basic only | Enhance for full schema (1-2 hrs) |
| **JSON Spec** | ⚠️ Outdated | Update to match schema (10 min) |

---

## 🎯 Recommended Immediate Action

**Fix the API routes right now** so your app works with your actual database schema. That's the only blocking issue.

Would you like me to:
1. ✅ **Fix all the API routes immediately?**
2. ✅ **Then enhance the ingestion script?**
3. ✅ **Create a sample JSON entry for testing?**

Say yes and I'll do all three in sequence.

