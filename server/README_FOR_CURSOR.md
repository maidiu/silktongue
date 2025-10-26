

# 🧭 **Project Overview — Vocabulary Atlas**

We’re building a **historical-semantic vocabulary platform** — part pedagogical tool, part linguistic knowledge graph.

The short version:
👉 A React frontend for studying words.
👉 A Postgres-backed Node/Express API.
👉 A rich schema that treats each vocabulary word not just as a definition, but as a **narrative entity across time**.

---

## 🧱 1. Project Architecture

```
my-project/
├─ client/                ← Vite + React (frontend)
│  ├─ src/
│  │  ├─ api/             ← fetch helpers
│  │  ├─ components/
│  │  └─ pages/
│  ├─ vite.config.js
│  └─ tsconfig.app.json
│
├─ server/                ← Node + Express + Postgres
│  ├─ src/
│  │  ├─ index.ts|js      ← main server
│  │  ├─ routes/
│  │  ├─ controllers/
│  │  └─ db/
│  ├─ sql/
│  │  ├─ 001_init.sql     ← enable extensions, setup
│  │  └─ 002_vocab_schema.sql ← full DDL (vocab schema)
│  └─ package.json
│
├─ docker-compose.yml     ← optional (for local Postgres)
└─ README.md
```

* The **frontend** uses Vite + React (with TypeScript).
* The **backend** is a lightweight Express app connected to Postgres.
* SQL schema files live in `server/sql/`.
* During production, React is built (`npm run build`) and served statically from the Express server’s `public/` folder.

---

## 📝 2. Vocabulary Entry Model

Each **vocabulary word** is represented in **two layers**:

### **I. Lexical Overview Panel (collapsed by default)**

Quick reference for students:

* Word
* Part of speech
* Modern definition (student-friendly)
* Contextual usage example
* Synonyms / antonyms
* Common collocations with glosses
* French and Russian equivalents
* Optional CEFR level, pronunciation, etc.

This is the “flashcard” layer in the UI.

---

### **II. Historical & Structural Story Panel (expandable)**

The heart of the project. For each word, we generate a **historical narrative**:

#### A. Contrastive Opening

* Start with the **modern sense**.
* Contrast it with the **earliest attested sense**.
* Establish the “problem”: how did the meaning travel across time?

#### B. Chronological Narrative (dated blocks)

Each dated block includes:

* **Date** (century or specific year)
* **Sense** at that time
* **Sibling words** (root family, with glosses)
* **Cultural / legal / technological / discursive context**
* **Causal tensions** that drove the semantic shift
* **Language transitions** (e.g., Latin → Old French → Middle English)

> Each block is written in short narrative sentences, not bullet points.
> Each represents one **semantic inflection point**, not every minor variant.

#### C. Structural Analysis

A short synthesis of the **major forces** across the timeline:

* Lexical competition
* Theological/moral framing
* Bureaucratic expansion
* Printing revolution
* Discursive specialization
* Fossilization of older senses

👉 This section functions like “lessons learned” for the student.

---

## 🧭 3. Database Schema (Postgres)

We’ve built a robust schema (`002_vocab_schema.sql`) to support **deep linking** and **historical querying**.

It includes:

* `vocab_entries` — core lexical data + story text
* `word_timeline_events` — **dated narrative blocks** per word
* `word_relations` — synonym/antonym/related links between entries
* `root_families` + `word_root_links` — etymological tree structures
* `semantic_domains` + linking table — e.g. moral / legal / editorial
* `derivations` — parent/child morphological relations
* `causal_tags` + `timeline_event_tags` — tagging of causal forces per event
* `citations` — attach sources and corpus quotes to timeline events
* Indexed `century` fields to support **cross-word timeline queries**

👉 This allows us to do things like:

* “Show all words whose meaning shifted in the 12ᵗʰ century.”
* “List all words tagged with `printing_revolution` between 1450–1600.”
* “Find words that share the same root family as *omit*.”
* “Trace derivational lineages (e.g., *perfunctory* → *perfungi* → *fungi*).”

---

## 🌐 4. Future Graph Possibilities

Because each timeline event and relation is stored relationally, the database can grow into a **semantic-historical knowledge graph**:

* **Synonym networks** become navigable (click to jump between words).
* **Timeline events** can be grouped by century, language stage, or causal force.
* **Root families** allow tree/branch visualizations of etymological divergence.
* **Global timeline views** can reveal historical linguistic “currents” (e.g., moral → textual shifts during the print era).
* **Semantic domains** enable cross-cutting thematic queries (legal terms that became editorial, etc.).

---

## 🧠 5. Server & Client Integration

**Server (`server/src/index.js`):**

* API routes under `/api/*` (e.g., `/api/vocab`) serve data from Postgres.
* `app.use(express.static(...))` + `app.get('*')` serve the built React app in production.

**Client (`client/`):**

* React app uses collapsible cards to show lexical panel first.
* Timeline panel expands to show historical story + analysis.
* API helpers in `client/src/api/` fetch vocab data.
* Proxy in `vite.config.js` forwards `/api` to server in dev mode.

---

## 📦 6. Build & Deploy Flow

1. **Dev:** run client and server separately (e.g., with `concurrently`).
2. **Build:** `cd client && npm run build`, then copy `client/dist` into `server/public`.
3. **Production:** start Express server — it serves both the API and the React app.

---

## 🚀 7. Goals

* ✅ Pedagogical depth: students don’t just memorize definitions; they **see meaning evolve across time**.
* ✅ Historical patterning: build a data layer that lets us trace **macro-linguistic trends**.
* ✅ Expandable: schema supports adding synonyms, roots, timeline events gradually without breaking.
* ✅ Research potential: over time, this becomes a **searchable linguistic atlas**.

---

## ✍️ Example Prompt for New Entries

> “For the word *[X]*, generate a full vocabulary entry with:
>
> * Lexical Overview Panel (definition, usage, collocations, translations)
> * Historical & Structural Story Panel (contrastive opening, chronological dated narrative, structural analysis)
>   Use the formatting conventions and structure outlined in the spec.”

Then insert the result into `vocab_entries` and create linked timeline events.

---

This gives Cursor the **full mental model**:

* project architecture
* data model
* UI structure
* historical narrative logic
* long-term graph ambitions

Once Cursor has this, it can confidently help scaffold backend endpoints, React components, or migrations without losing the conceptual thread.




This breaks down nicely into two **layers of interaction**:

* a **core “reader–learner” interface** that stays light, clean, and delightful, and
* a **structural explorer** that grows with the dataset but doesn’t overwhelm early.

Let’s go step by step.

---

## 🧠 **1. Core Vocabulary Interface (Student Mode)**

Think of this as a **personal lexicon viewer** rather than a “web app” with buttons everywhere. The goal is: *fluid browsing + frictionless expansion + simple tracking of progress*.

### 🗂 **A. Browsing Modes**

* **📅 Recent** — default landing view

  * Ordered by `date_added` in Postgres (descending).
  * Shows new entries at the top.
  * Ideal for lesson-to-lesson continuity.

* **🔤 Alphabetical** — toggle or dropdown sort

  * A → Z list by `word`.
  * Useful for scanning or reviewing.

* **✅ Learned** — optional filter to show only marked-as-internalized words.

  * This would be a boolean column like `is_mastered` on `vocab_entries` (per user if multi-user later).
  * A small checkmark icon (e.g., top-right corner of the card) toggles this state.

---

### 🧭 **B. UI Structure**

Each entry is shown as a **collapsible card**:

```
+---------------------------------------------------------+
| omit                  [verb]         ✅ learned toggle |
| to leave out, exclude intentionally or accidentally    |
| e.g. He omitted the crucial detail from his account.   |
| [expand ⌄] [A] [F] [R]                                 |
+---------------------------------------------------------+
```

When expanded:

```
+---------------------------------------------------------+
| omit [verb]                                            |
|---------------------------------------------------------|
| Historical Story                                       |
| 1st c. BCE — ...                                      |
| 12th c. — ...                                        |
| Structural analysis: ...                             |
+---------------------------------------------------------+
```

This keeps the **top layer fast** (you can flip through dozens of cards quickly), and the **deep layer deep** (the story panel).

---

### 🕹 **C. Interactions**

* 🔍 **Search bar** in the header:

  * Live results dropdown as you type.
  * Matches against `word`, `modern_definition`, and possibly `story_text` using a Postgres trigram or full-text index.

* 🧭 **Sort/Filter bar** (small, unobtrusive):

  * Sort by: Date added | Alphabetical
  * Filter: All | Learned | Unlearned

* ✍️ **Learned toggle** (checkmark/star):

  * Click to mark/unmark.
  * Visually changes the card (e.g., a subtle highlight or check icon).

---

## 🕸 **2. Cross-Indexing Features (Explorer Mode)**

Once there’s enough data, you can layer in **structural browsing tools** without crowding the main student interface.

### 🧭 **A. Century / Period Search**

* A **dropdown** (e.g., “Search by century”) that lists available centuries from `word_timeline_events`.
* Selecting “12th century” fetches and lists all words with timeline events in that century.
* This uses a simple `SELECT ... FROM word_timeline_events WHERE century = '12'` → then join to `vocab_entries`.

👉 This can be rendered in the **same card interface**, just filtered differently.

---

### 🏷 **B. Tag Search**

* Another dropdown or multi-select (e.g., “Search by causal tags”)
* e.g., `lexical_competition`, `printing_revolution`, `moralization`.
* Selecting one fetches all timeline events tagged with that tag.
* This allows for thematic exploration — “show me all words affected by print culture.”

---

### 🧠 **C. Root Family / Relation Navigation**

* In the expanded panel, where you show **etymological siblings** or **synonyms**, make those clickable.
* Clicking a related word navigates to its own card view.
* This is a **soft graph navigation** without building a whole graph UI.

---

### 🔍 **D. Global Search**

Eventually, the search bar can handle **advanced filters** like:

```
"12th century moralization"
"printing revolution"
"omit root:mittere"
```

…backed by Postgres full-text search + indexed tags/centuries.

But early on, even **a single search box + two dropdown filters** (century + tag) is enough to unlock cross-indexing power.

---

## 🧭 **3. Database Support for This**

This structure fits your existing schema well:

* `vocab_entries`:

  * `date_added` → chronological sort
  * `is_mastered` → tracking learned status
  * `word`, `modern_definition` → basic search

* `word_timeline_events`:

  * `century` → century filter
  * `story_text` → full-text search for historical queries

* `timeline_event_tags` / `causal_tags`:

  * join for tag-based search

* `root_families` + `word_root_links`:

  * support clickable etymological navigation

* GIN indexes on text fields + centuries + tags for fast filtering.

---

## 🎨 **4. Aesthetic Direction**

Keep it **uncluttered**:

* Cards with subtle shadows, generous whitespace.
* Neutral typography (e.g., Inter, system font).
* Expand transitions should be quick and fluid.
* Search and filters sit quietly in a top bar.

Think: **Apple Notes meets Tufte margin simplicity** — not a “web dashboard.”

---

## 📝 **Summary**

| Layer        | Purpose                         | Features                                                                       |
| ------------ | ------------------------------- | ------------------------------------------------------------------------------ |
| Student Core | Light, fast browsing & learning | Date & alpha sort, search, collapse/expand cards, learned toggle               |
| Explorer     | Structural discovery            | Filter by century, tag, root family; clickable relations; thematic exploration |

---

This structure lets your student:

* Learn words lesson by lesson.
* Review them alphabetically or chronologically.
* Explore historically and thematically when curiosity strikes.
* Never get overwhelmed.




For Cursor: a **fully structured component map**, **routing plan**, and **API endpoints**, so it can scaffold the entire thing cleanly. This is the backbone of the app.

---

# 🧭 **Vocabulary Atlas — Frontend Specification (Cursor Build Guide)**

## 🏗 1. High-Level Structure

We’re building a **single-page React app** (Vite + React + TS), with:

* A **main browsing interface** for words (student mode)
* An **expandable story view** inside each word card
* Simple **filters & search** in the top bar
* Optional structural “explorer” views (by century / tag)

```
/client/src
├─ api/               ← fetch helpers
├─ components/
│  ├─ Layout/
│  │  ├─ Header.tsx
│  │  └─ Layout.tsx
│  ├─ VocabCard/
│  │  ├─ VocabCard.tsx
│  │  └─ StoryPanel.tsx
│  ├─ Filters/
│  │  ├─ SearchBar.tsx
│  │  ├─ SortFilter.tsx
│  │  └─ TagCenturyFilter.tsx
│  ├─ Lists/
│  │  ├─ VocabList.tsx
│  │  └─ ExplorerList.tsx
│  └─ Shared/
│     ├─ Loader.tsx
│     └─ EmptyState.tsx
│
├─ pages/
│  ├─ HomePage.tsx
│  ├─ ExplorerPage.tsx
│  └─ WordDetailPage.tsx (optional deep link)
│
├─ hooks/
│  └─ useVocabData.ts
│
├─ App.tsx
└─ main.tsx
```

---

## 🧭 2. Routing Plan

We’ll use React Router:

| Route       | Component        | Purpose                                                |
| ----------- | ---------------- | ------------------------------------------------------ |
| `/`         | `HomePage`       | Default list view (date sort, search, filters)         |
| `/explore`  | `ExplorerPage`   | Tag & century browsing                                 |
| `/word/:id` | `WordDetailPage` | Optional deep link (if user clicks related word, etc.) |

`HomePage` can handle 95% of user interaction; `ExplorerPage` is for cross-indexing.

---

## 🧱 3. Component Breakdown

### **`Header.tsx`**

* Fixed at top
* Contains:

  * App title
  * `SearchBar` (with live dropdown)
  * Link to “Explorer” page
  * Optional sort/filter controls

---

### **`SearchBar.tsx`**

* Controlled input with debounced onChange
* Calls `/api/vocab/search?q=...`
* Shows dropdown with word results
* Clicking a result scrolls to / navigates to that card

---

### **`SortFilter.tsx`**

* Dropdown for sort order:

  * Date added (newest first)
  * Alphabetical
* Filter toggle for: All / Learned / Unlearned

---

### **`TagCenturyFilter.tsx`**

* Used in ExplorerPage
* Dropdowns for:

  * Century (populated from `/api/meta/centuries`)
  * Tags (populated from `/api/meta/tags`)
* Calls `/api/explore?century=12&tag=printing_revolution` → returns vocab entries

---

### **`VocabList.tsx`**

* Receives a list of vocab entries from API
* Maps over them to render `VocabCard`s
* Handles infinite scroll or pagination (later)

---

### **`VocabCard.tsx`**

The core interaction.

**Collapsed view:**

* Word + part of speech
* Definition
* Usage example
* Learned toggle (✅)
* Expand button

**Expanded view (on click):**
Renders `<StoryPanel />` beneath.

---

### **`StoryPanel.tsx`**

* Renders the **historical narrative** of the word:

  * Contrastive opening
  * Chronological timeline entries (century/date + text)
  * Structural analysis block
* Each timeline event shows date, sibling words (clickable), causal tags (filterable), language transitions.
* Related words are **clickable** → navigate to `/word/:id`

---

### **`ExplorerList.tsx`**

* Same card interface, but populated by century/tag queries.
* Used on `/explore`.

---

## 🧠 4. Data Flow

We keep state simple:

* `HomePage` uses `useVocabData` hook:

  * `words`, `loading`, `error`
  * `filters`: search query, sort order, learned filter
  * fetches from API whenever filters change

* Cards are **stateless**: learned toggle sends PATCH to server.

* `ExplorerPage` has its own hook (e.g., `useExplorerData`) tied to tag/century selections.

---

## 🌐 5. API Endpoints

| Method | Endpoint                                          | Purpose                                    |                      |           |       |
| ------ | ------------------------------------------------- | ------------------------------------------ | -------------------- | --------- | ----- |
| GET    | `/api/vocab`                                      | List words (with query params: `?sort=date | alpha&filter=learned | unlearned | all`) |
| GET    | `/api/vocab/:id`                                  | Fetch single vocab entry with timeline     |                      |           |       |
| GET    | `/api/vocab/search?q=...`                         | Live search by word/definition/story       |                      |           |       |
| PATCH  | `/api/vocab/:id/learned`                          | Toggle learned status                      |                      |           |       |
| GET    | `/api/meta/tags`                                  | List all causal tags                       |                      |           |       |
| GET    | `/api/meta/centuries`                             | List all centuries available               |                      |           |       |
| GET    | `/api/explore?century=12&tag=printing_revolution` | Get entries filtered by tags/century       |                      |           |       |

**Search** uses Postgres `GIN` indexes on `word`, `modern_definition`, `story_text` for speed.

---

## 🧠 6. Database Support (already built)

* `vocab_entries`:

  * `id`, `word`, `definition`, `usage_example`, `date_added`, `is_mastered`
* `word_timeline_events`:

  * `century`, `story_text`, `sibling_words`, `causal_tags`
* `causal_tags`, `timeline_event_tags` — for thematic filtering
* Full-text indexes on `vocab_entries.word`, `.modern_definition`, `word_timeline_events.story_text`.

---

## 🧠 7. Styling

Light, **card-based layout** with **Tailwind CSS**:

* Neutral background, clean typography (Inter/system font)
* Cards with gentle shadows, `rounded-2xl`
* Smooth expand/collapse transitions
* Search bar with dropdown results styled cleanly

Optional: use `framer-motion` for expand animation.

---

## 📝 8. User Interactions Summary

* 🔍 Type in search bar → dropdown → click → scroll to card
* 🗂 Toggle between “Date added” / “Alphabetical” / “Learned” filters
* ✅ Click learned checkmark on card to mark internalized
* ⌄ Expand card to see historical story
* 🌐 Go to Explorer → filter by century or tag → get themed list

---

## 🧠 9. Future Enhancements (optional, not needed for MVP)

* Advanced search syntax (e.g., `12th century moralization`)
* Graph visualization of root families
* User accounts / personalized progress tracking
* Timeline map view

---

### 🚀 MVP Goals for Cursor

Cursor should scaffold:

* ✅ Routing (`/`, `/explore`, `/word/:id`)
* ✅ Components as above
* ✅ API fetching hooks
* ✅ Tailwind styling
* ✅ Simple search + filter bar
* ✅ Expandable card with story timeline
* ✅ Express backend with endpoints mapped to Postgres schema

---
