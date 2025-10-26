# 🚨 Implementation Gap Analysis: Current vs. README2.md

## Executive Summary

Your **database schema (004_updated_vocab_schema.sql)** is robust and complete, but your **API routes** and **ingestion script** are not aligned with it. This is causing the app to fail when trying to display vocabulary entries.

---

## ✅ What EXISTS and WORKS

### Database Schema (`004_updated_vocab_schema.sql`)
- ✅ `vocab_entries` with all core fields
- ✅ `word_timeline_events` with century tracking (TEXT + generated INT + TEXT[])
- ✅ `causal_tags` + `timeline_event_tags` (many-to-many linking)
- ✅ `word_relations` (synonym/antonym/related graph)
- ✅ `root_families` + `word_root_links` (etymological trees)
- ✅ `semantic_domains` + `vocab_domain_links`
- ✅ `derivations` (morphological parent/child)
- ✅ `citations` (source anchoring)
- ✅ **GIN full-text search indexes** on word, definition, story_text
- ✅ **century_summary view** for Explorer page
- ✅ Extensions: `pg_trgm`, `btree_gin`

### API Routes (Partial)
- ✅ `/api/meta/tags` - works correctly
- ✅ `/api/meta/centuries` - works correctly  
- ✅ `/api/explore` - works correctly (joins timeline + tags)
- ⚠️ `/api/vocab` routes - **BROKEN** (column mismatches)

---

## 🚨 What's BROKEN

### 1. **`/api/vocab` - List Endpoint** (`vocab.js` lines 23-32)

**Problem:** Queries for columns that **don't exist** in your schema:

```javascript
// CURRENT (BROKEN):
SELECT synonyms, antonyms, collocations, 
       french_equivalent, russian_equivalent, 
       cefr_level, pronunciation
FROM vocab_entries

// ACTUAL SCHEMA:
// - NO synonyms/antonyms columns (use word_relations instead)
// - NO collocations (should be common_collocations)
// - NO french_equivalent (should be french_equiv)
// - NO russian_equivalent (should be russian_equiv)
// - NO cefr_level (doesn't exist)
// - NO pronunciation (doesn't exist)
```

**Fix Required:**
- Remove non-existent columns from SELECT
- Join `word_relations` to build synonyms/antonyms arrays dynamically
- Rename columns to match schema

---

### 2. **`/api/vocab/search`** (`vocab.js` lines 51-68)

**Problem:** Tries to search `story_text` column on `vocab_entries`, but it's in `word_timeline_events`:

```javascript
// CURRENT (BROKEN):
WHERE story_text ILIKE $1  -- story_text not on vocab_entries!

// FIX:
// Need to JOIN word_timeline_events to search story_text
```

---

### 3. **`/api/vocab/:id` - Single Entry Endpoint** (`vocab.js` lines 78-158)

**Multiple Problems:**

#### a. Main entry query (lines 84-93) references non-existent columns:
```javascript
// BROKEN:
SELECT synonyms, antonyms, collocations,
       french_equivalent, russian_equivalent,
       cefr_level, pronunciation,
       story_text, contrastive_opening  -- these don't exist!
```

#### b. Timeline query (lines 104-112) uses wrong column names:
```javascript
// BROKEN:
SELECT century, year, sense_at_time, sibling_words,
       cultural_context, causal_tensions, 
       language_transitions, event_text, sort_order

// ACTUAL SCHEMA HAS:
// - century ✅
// - NO year ❌
// - NO sense_at_time ❌
// - sibling_words ✅
// - context (not cultural_context) ⚠️
// - NO causal_tensions ❌
// - NO language_transitions ❌
// - story_text (not event_text) ⚠️
// - NO sort_order ❌
```

#### c. Relations query (lines 129-137) uses wrong column names:
```javascript
// BROKEN:
FROM word_relations wr
WHERE wr.vocab_entry_id = $1  -- should be source_id
  AND wr.related_word_id = $1  -- should be target_id
```

#### d. Root family query (lines 140-147) uses wrong column names:
```javascript
// BROKEN:
SELECT rf.root_word, rf.language, rf.meaning

// ACTUAL SCHEMA:
// - root_name (not root_word)
// - language_origin (not language)
// - gloss (not meaning)
```

---

### 4. **Ingestion Script** (`ingest_vocab.js`)

**Problem:** Script only handles **basic fields** from JSON, missing:

- ❌ `common_collocations` (not ingested)
- ❌ `structural_analysis` (not ingested)
- ❌ `sibling_words` in timeline events (not ingested)
- ❌ `context` in timeline events (not ingested)
- ❌ Root family links (not created)
- ❌ Semantic domain links (not created)
- ❌ Derivations (not created)
- ❌ Citations (not created)

**Current ingestion only handles:**
```javascript
// Fields ingested:
- word, part_of_speech, modern_definition
- usage_example, french_equiv, russian_equiv
- synonyms → word_relations (synonym)
- antonyms → word_relations (antonym)
- related → word_relations (related)
- story[] → word_timeline_events (century, story_text)
```

---

### 5. **Frontend TypeScript Interface Mismatch**

**`client/src/api/vocab.ts` VocabEntry interface** expects:
```typescript
interface VocabEntry {
  // Uses snake_case like french_equivalent, russian_equivalent
  // But schema has french_equiv, russian_equiv
  
  synonyms?: string[]          // doesn't exist as column
  antonyms?: string[]          // doesn't exist as column
  collocations?: any           // should be common_collocations
  cefr_level?: string          // doesn't exist
  pronunciation?: string       // doesn't exist
  story_text?: string          // doesn't exist on vocab_entries
  contrastive_opening?: string // doesn't exist
}
```

---

## 🛠️ What Needs to Be Built

### **Priority 1: Fix API Routes** (CRITICAL - App currently broken)

1. **Fix `/api/vocab` list endpoint**
   - Remove non-existent columns
   - Add subqueries or JOINs to build synonyms/antonyms from `word_relations`
   - Rename `french_equivalent` → `french_equiv`, etc.

2. **Fix `/api/vocab/search`**
   - JOIN `word_timeline_events` to search `story_text`
   - Remove references to non-existent columns

3. **Fix `/api/vocab/:id` single entry endpoint**
   - Correct all column names in main query
   - Fix timeline query column names
   - Fix relations query to use `source_id`/`target_id`
   - Fix root query to use `root_name`/`gloss`
   - Add queries for semantic domains, derivations, citations

---

### **Priority 2: Enhance Ingestion Script** (For weekly workflow)

Create **enhanced `ingest_vocab.js`** that handles:

1. **Full vocab_entries fields:**
   - `common_collocations` TEXT[]
   - `structural_analysis` TEXT

2. **Enhanced timeline events:**
   - `sibling_words` TEXT[]
   - `context` TEXT

3. **Root family linking:**
   - Parse root info from JSON
   - Insert into `root_families`
   - Create `word_root_links`

4. **Semantic domain linking:**
   - Parse domain tags
   - Insert into `semantic_domains`
   - Create `vocab_domain_links`

5. **Derivations:**
   - Parse parent/child relations
   - Insert into `derivations`

6. **Citations:**
   - Parse citation data
   - Link to specific timeline events

---

### **Priority 3: Align Frontend TypeScript Interface** (Type safety)

Update `client/src/api/vocab.ts`:
```typescript
export interface VocabEntry {
  id: number;
  word: string;
  part_of_speech?: string;
  modern_definition?: string;
  usage_example?: string;
  common_collocations?: string[];  // ⚠️ changed from collocations
  french_equiv?: string;            // ⚠️ changed from french_equivalent
  russian_equiv?: string;           // ⚠️ changed from russian_equivalent
  structural_analysis?: string;
  is_mastered: boolean;
  date_added: string;
  
  // Computed from relations:
  synonyms?: string[];              // Built from word_relations
  antonyms?: string[];              // Built from word_relations
  related_words?: string[];         // Built from word_relations
  
  // Timeline data (when fetching single entry):
  timeline_events?: TimelineEvent[];
  roots?: RootFamily[];
  domains?: string[];
  derivations?: Derivation[];
  citations?: Citation[];
}
```

---

### **Priority 4: Add Missing API Endpoints** (Optional enhancements per README2.md)

1. **`/api/vocab/:id/relations`** - Get word relation graph
2. **`/api/family/:root_id`** - Get all words from a root family
3. **`/api/domains`** - List all semantic domains
4. **`/api/vocab/by-domain/:domain_id`** - Filter by semantic domain

---

## 📊 Summary Table

| Component | Status | Action Required |
|-----------|--------|----------------|
| **Database Schema** | ✅ Complete | None - schema is solid |
| **API `/api/meta/*`** | ✅ Working | None |
| **API `/api/explore`** | ✅ Working | None |
| **API `/api/vocab`** | 🚨 Broken | Fix column names + joins |
| **API `/api/vocab/search`** | 🚨 Broken | Add JOIN for story_text |
| **API `/api/vocab/:id`** | 🚨 Broken | Fix all column names |
| **Ingestion Script** | ⚠️ Partial | Add full JSON support |
| **Frontend Types** | ⚠️ Misaligned | Update interfaces |
| **Advanced API Routes** | ❌ Missing | Optional - build if needed |

---

## 🎯 Recommended Implementation Order

1. **Fix `vocab.js` API routes** (30 min) - makes app functional
2. **Update frontend TypeScript interfaces** (10 min) - removes type errors
3. **Test with existing data** (10 min) - verify everything works
4. **Enhance ingestion script** (1-2 hours) - enables full JSON spec
5. **Create sample JSON entry** (30 min) - test end-to-end
6. **Add advanced API endpoints** (optional, 1-2 hours)

---

## Next Steps

Would you like me to:
1. **Fix the broken API routes immediately** (Priority 1)?
2. **Create the enhanced ingestion script** (Priority 2)?
3. **Both, in sequence**?

The app is currently non-functional because the API is querying for columns that don't exist. We should fix this first.

