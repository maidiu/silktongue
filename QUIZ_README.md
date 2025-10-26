🧩 Goal

Build a Spelling Puzzle React component where the player drags moving letter blocks to arrange them into the correct order for a word.

When the letters are arranged correctly:

The word “locks in” with a glow animation.

A callback (onSuccess) fires, which will later award silk or unlock the next quiz level.

🪶 Functional Requirements

Input Props

interface SpellingPuzzleProps {
  word: string;              // the target word to spell
  onSuccess?: () => void;    // fires when the user spells it correctly
}


Behavior

The word’s letters are scrambled on mount.

Each letter renders as a draggable block.

Player can drag-and-drop to reorder.

When the current order matches the target spelling (case-insensitive),
trigger success state:

Blocks glow briefly.

onSuccess() executes.

Visuals

Blocks appear to “float” (slight idle animation or random drift).

Correct placement triggers a soft pulse glow (CSS or Framer Motion).

Background: subtle silk-like gradient (optional).

Libraries

Use react-beautiful-dnd or @dnd-kit/core (lighter, modern).

Use framer-motion for gentle movement.

CSS via Tailwind (already in your stack).

🧱 Implementation Steps

Install packages

npm install @dnd-kit/core framer-motion


Create component
client/src/components/SpellingPuzzle.jsx

import { useState, useEffect } from 'react';
import { DndContext, closestCenter, useSensor, useSensors, PointerSensor, KeyboardSensor } from '@dnd-kit/core';
import { arrayMove, SortableContext, sortableKeyboardCoordinates, rectSortingStrategy } from '@dnd-kit/sortable';
import { SortableItem } from './SortableItem';
import { motion } from 'framer-motion';

export default function SpellingPuzzle({ word, onSuccess }) {
  const letters = word.toUpperCase().split('');
  const [items, setItems] = useState([]);

  useEffect(() => {
    const shuffled = [...letters].sort(() => Math.random() - 0.5);
    setItems(shuffled);
  }, [word]);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
  );

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (active.id !== over.id) {
      setItems((items) => {
        const oldIndex = items.indexOf(active.id);
        const newIndex = items.indexOf(over.id);
        const newOrder = arrayMove(items, oldIndex, newIndex);

        if (newOrder.join('') === letters.join('')) {
          if (onSuccess) onSuccess();
        }
        return newOrder;
      });
    }
  };

  return (
    <div className="flex flex-col items-center mt-8">
      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
        <SortableContext items={items} strategy={rectSortingStrategy}>
          <div className="flex gap-3">
            {items.map((id, i) => (
              <motion.div
                key={id}
                animate={{ y: [0, -2, 0] }}
                transition={{ repeat: Infinity, duration: 2, delay: i * 0.1 }}
              >
                <SortableItem id={id} />
              </motion.div>
            ))}
          </div>
        </SortableContext>
      </DndContext>
    </div>
  );
}


Add SortableItem helper
client/src/components/SortableItem.jsx

import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

export function SortableItem({ id }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id });
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      className="w-14 h-14 bg-purple-200 dark:bg-purple-600 flex items-center justify-center text-2xl font-semibold rounded-xl shadow-md cursor-grab select-none hover:bg-purple-300 dark:hover:bg-purple-500"
    >
      {id}
    </div>
  );
}


Use it anywhere

import SpellingPuzzle from '../components/SpellingPuzzle';

export default function LevelOne() {
  const handleSuccess = () => {
    console.log('✔ Word spelled correctly!');
    // call server endpoint to award silk
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center">
      <SpellingPuzzle word="Perfunctory" onSuccess={handleSuccess} />
    </div>
  );
}

🕹 Optional Enhancements

Health loss on fail:
Add a “Check” button; wrong order subtracts one HP.

Floating animation:
Wrap letters in <motion.div> with random small drift (Framer Motion’s animate={{ x: [0, 1, 0], y: [0, -1, 0] }} loops).

Server integration:
When onSuccess fires, call:

fetch('/api/quiz/level-complete', {
  method: 'POST',
  headers: {'Content-Type':'application/json'},
  body: JSON.stringify({ word: 'perfunctory', level: 1 })
});


Accessibility:
Add keyboard drag sensors and ARIA labels.

🧠 Deliverables

Cursor should create:

/client/src/components/SpellingPuzzle.jsx

/client/src/components/SortableItem.jsx

Update any level page or quiz route to include the new puzzle.





Silktongue Quiz System — A Ritual of Mastery

Silktongue’s quizzes are not menus.
Each word is a short ascent—five chambers of understanding.
Every chamber tests a deeper kind of knowing; each one opens only when the previous is completed.
When the fifth gate closes, the word releases silk.

🌒 EXPERIENCE OVERVIEW

A quiz should feel like progression through light and sound, not a series of checkboxes.

Each stage:

Focuses on one type of knowledge.

Has its own atmosphere (animation, tone, texture).

Ends with a visible transformation—the screen breathes, the word stabilizes, silk threads appear.

The five stages form a climb:

Stage	Essence	Gesture
I. Form – Recognition	Arrange letters to give the word its body.	Hands, motion.
II. Memory – Recall	Type it from nothing.	Precision, rhythm.
III. Meaning – Comprehension	Choose the right definition from glowing thoughts.	Intuition.
IV. Relation – Connection	Draw words toward or away: synonym or antonym.	Judgment.
V. Story – Integration	Order the word’s history into sense.	Understanding.
🧱 ARCHITECTURE
Directory Structure
client/src/
  components/
    LevelScene.jsx
    SpellingPuzzle.jsx
    TypeWordChallenge.jsx
    MeaningMatch.jsx
    SynAntDuel.jsx
    StorySequence.jsx
  hooks/
    useQuizProgress.js
  pages/
    QuizPage.jsx

Core Component: QuizPage.jsx

QuizPage manages the state machine of levels.

import { useQuizProgress } from '../hooks/useQuizProgress';
import { motion, AnimatePresence } from 'framer-motion';

export default function QuizPage({ word }) {
  const { level, advance, health, silk } = useQuizProgress(word);

  const scenes = [
    <SpellingPuzzle word={word} onSuccess={advance} />,
    <TypeWordChallenge word={word} onSuccess={advance} />,
    <MeaningMatch word={word} onSuccess={advance} />,
    <SynAntDuel word={word} onSuccess={advance} />,
    <StorySequence word={word} onSuccess={advance} />,
  ];

  return (
    <div className="min-h-screen flex flex-col items-center justify-center relative overflow-hidden">
      <AnimatePresence mode="wait">
        <motion.div
          key={level}
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -40 }}
          transition={{ duration: 0.6 }}
        >
          {scenes[level - 1]}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

useQuizProgress.js

Manages level, health, silk, and API sync.

import { useState } from 'react';

export function useQuizProgress(word) {
  const [level, setLevel] = useState(1);
  const [health, setHealth] = useState(5);
  const [silk, setSilk] = useState(0);

  const advance = async () => {
    const res = await fetch('/api/quiz/level-complete', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ word, level }),
    });
    const data = await res.json();
    setLevel(data.level);
    setSilk(data.silk);
  };

  return { level, advance, health, silk };
}

🌀 LEVEL SCENE SPEC

All levels share this wrapper:

export default function LevelScene({ title, instruction, children }) {
  return (
    <div className="flex flex-col items-center justify-center gap-4 text-center">
      <h2 className="text-2xl font-bold tracking-wide">{title}</h2>
      <p className="opacity-75 max-w-md">{instruction}</p>
      <div className="mt-6">{children}</div>
    </div>
  );
}


Each component (SpellingPuzzle, MeaningMatch, etc.) plugs into this.

✨ LEVEL SUMMARIES FOR CURSOR
Level I – SpellingPuzzle

Floating letter blocks (already built).

Goal: arrange correctly → glow pulse → advance.

Level II – TypeWordChallenge

Empty field + subtle timer bar.

Regex ignores case.

Success = green shimmer, failure = one HP lost.

Level III – MeaningMatch

4–5 definition cards orbit gently (Framer Motion).

Correct choice → bloom animation; wrong → brief red flicker.

Cursor should fetch definitions from /api/quiz/:wordId/definitions.

Level IV – SynAntDuel

Two magnetic zones: “Draw Near” and “Repel.”

Floating word orbs drag to zones.

Full correct placement triggers pulse of unity.

Level V – StorySequence

Scrollable silk-textured backdrop.

Draggable story cards (each from story_text).

Correct order = radiant alignment + silk awarded.

🧩 SERVER ENDPOINTS
POST /api/quiz/start/:wordId
POST /api/quiz/level-complete
POST /api/quiz/fail
GET  /api/user/stats


level-complete handles silk logic:

UPDATE users
SET silk_balance = silk_balance + 5
WHERE id = $1
AND NOT EXISTS (SELECT 1 FROM quizzes WHERE user_id=$1 AND word_id=$2 AND completed_at IS NOT NULL);

CONTENT INGESTION (Human-Authored)

All quiz content — definitions, synonyms, antonyms, and story data — is written and curated manually.

Every week, a new JSON file is added to /server/data/weekly/ in this shape:

{
  "word": "perfunctory",
  "definitions": ["done without care", "performed as routine"],
  "synonyms": ["cursory", "mechanical"],
  "antonyms": ["thorough", "attentive"],
  "story": [
    {"century": "1", "story_text": "Latin perfungi — to get through a duty."},
    {"century": "19", "story_text": "Industrial era — mechanical labor."}
  ]
}

Ingestion Script

/server/scripts/ingest_quizzes.js reads those JSONs and updates the database.

Cursor’s responsibility:

Validate JSON shape (log errors, skip malformed files).

Upsert or insert quiz data for each word.

Sync to vocab_entries or a quiz_materials table.

Do not auto-generate or rewrite content.

Human-authored text is authoritative.

ingest_quizzes.js will upsert these into Postgres, mirroring ingest_vocab.js.



🌿 DESIGN GUIDELINES

No tables.
Every stage is a full-screen experience.

Light and motion are the only UI constants.

Failure should feel like learning, not punishment.

Progress should feel embodied—fingers, eyes, rhythm.

Silk accumulation screen: minimalist, glowing tally at the top right.