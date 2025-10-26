# Quiz System Structure

## Overview
The quiz system uses a 5-level structure with properly designed question types. `sample_quiz3.json` provides the canonical structure.

## Level Types

### Level 1: Spelling Puzzle
- **Type**: `spelling`
- **Component**: `SpellingPuzzle`
- **Structure**:
  ```json
  {
    "level": 1,
    "question_type": "spelling",
    "prompt": "Arrange the letters to spell the word:",
    "options": null,
    "correct_answer": "perfunctory"
  }
  ```
- **Behavior**: Letters are auto-scrambled. User drags to arrange them.

### Level 2: Typing Challenge
- **Type**: `typing`
- **Component**: `TypeWordChallenge`
- **Structure**:
  ```json
  {
    "level": 2,
    "question_type": "typing",
    "prompt": "Type the word you just arranged:",
    "options": null,
    "correct_answer": "perfunctory",
    "variant_data": {
      "case_insensitive": true
    }
  }
  ```
- **Behavior**: User types the word from memory.

### Level 3: Definition Match
- **Type**: `definition`
- **Component**: `MeaningMatch`
- **Structure**:
  ```json
  {
    "level": 3,
    "question_type": "definition",
    "prompt": "Select all definitions that accurately describe 'perfunctory':",
    "options": {
      "incorrect_answers": [
        "Executed with great attention and care",
        "Expressing heartfelt enthusiasm",
        ...8 total incorrect answers
      ],
      "correct_answers": [
        "Done quickly and without genuine interest",
        "Performed merely as a duty or routine",
        ...4 total correct answers
      ]
    },
    "variant_data": {
      "min_correct_to_pass": 3
    }
  }
  ```
- **Behavior**: 
  - System randomly selects 3 incorrect + 1 correct answer
  - Displays 4 total options
  - User must select the 1 correct answer
  - Can be configured for multiple correct selections with `min_correct_to_pass`

### Level 4: Synonym/Antonym Sort
- **Type**: `synonym`
- **Component**: `SynAntDuel`
- **Structure**:
  ```json
  {
    "level": 4,
    "question_type": "synonym",
    "prompt": "Drag each word into the correct basket for 'perfunctory':",
    "options": {
      "synonyms": ["cursory", "mechanical", "superficial", "routine"],
      "antonyms": ["thorough", "careful", "attentive", "conscientious"],
      "red_herrings": ["predictable", "tedious", "formal", "repetitive"]
    },
    "variant_data": {
      "min_correct_to_pass": 6
    }
  }
  ```
- **Behavior**: User drags words into 3 baskets: synonyms, antonyms, red herrings.

### Level 5: Story Sequence
- **Type**: `story`
- **Component**: `StorySequence`
- **Structure**:
  ```json
  {
    "level": 5,
    "question_type": "story",
    "prompt": "Match each time period with its stage in the story...",
    "options": {
      "time_periods": ["1st c. CE", "12th c.", "16th c.", "19th c.", "21st c."],
      "settings": ["Rome", "Medieval Church", "Renaissance Humanism", "Industrial Age", "Digital Life"],
      "turns": [
        "He worked among Roman officials who prized completion over feeling.",
        "He became a prayer said by habit—words without heart.",
        ...
      ]
    },
    "correct_answer": [
      "1st c. CE — Rome → He worked among Roman officials...",
      "12th c. — Medieval Church → He became a prayer...",
      ...
    ]
  }
  ```
- **Behavior**: 
  - Left column: time_periods (fixed)
  - Middle column: settings (draggable to reorder)
  - Right column: turns (draggable to reorder)
  - User must arrange middle and right columns to match the sequence

### Level 6 (Optional Hard Mode)
- Same as Level 5 but with `red_herrings` mixed in
- **Structure**:
  ```json
  {
    "level": 6,
    "difficulty": "hard",
    "options": {
      "time_periods": [...correct periods + false periods],
      "settings": [...correct settings + false settings],
      "turns": [...correct turns + false turns],
      "red_herrings": ["False statement 1", "False statement 2", ...]
    },
    "variant_data": {
      "hard_mode_penalty": {
        "health_loss_on_fail": 2,
        "reward_multiplier_on_success": 2
      }
    }
  }
  ```
- **Note**: Currently schema limits levels to 1-5. Need to expand if Level 6 is desired.

## Database Schema

The `quiz_materials` table stores:
- `word_id` (references `vocab_entries.id`)
- `level` (1-5, constrained by CHECK)
- `question_type` (enum: spelling, typing, definition, synonym, antonym, story)
- `prompt` (text)
- `options` (jsonb) - structure varies by question type
- `correct_answer` (text or jsonb array for story sequences)
- `variant_data` (jsonb) - additional config like min_correct_to_pass, feedback, etc.
- `reward_amount` (integer)

## Ingestion

Use `server/scripts/ingest_quiz3.js` to ingest quiz files that follow the `sample_quiz3.json` structure.

```bash
node server/scripts/ingest_quiz3.js
```

The script:
1. Looks up `word_id` from `word` name
2. Validates question structure
3. Inserts or updates `quiz_materials` entries
4. Handles JSON serialization for `options`, `correct_answer`, and `variant_data`

## API Routes

### GET `/api/quiz/word/:wordId`
Returns all quiz questions for a word, ordered by level.

### POST `/api/quiz/start/:wordId`
Starts or resumes a quiz, returns current progress.

### POST `/api/quiz/level-complete`
Records completion of a level, advances to next level.

### POST `/api/quiz/fail`
Records a failure, deducts health.

### GET `/api/quiz/stats`
Returns user's overall quiz stats (silk balance, words mastered, etc.)

## Frontend Components

- `QuizPage.tsx` - Main orchestrator
- `SpellingPuzzle.tsx` - Level 1
- `TypeWordChallenge.tsx` - Level 2
- `MeaningMatch.tsx` - Level 3 (also used for simple story questions)
- `SynAntDuel.tsx` - Level 4
- `StorySequence.tsx` - Level 5/6
- `LevelScene.tsx` - Generic wrapper for consistent styling

## Key Implementation Details

1. **Definition Questions**: The frontend randomly selects 3 incorrect + 1 correct answer from the pools each time the question is displayed.

2. **Story Sequences**: The `correct_answer` field contains an array of strings in the format `"time_period — setting → turn"`. The frontend parses these to create the matching UI.

3. **Red Herrings**: For synonym/antonym sorting and hard mode story sequences, red herrings are stored in `options.red_herrings` and presented alongside correct options.

4. **Difficulty**: Hard mode is indicated by `difficulty: "hard"` or `variant_data.difficulty === "hard"`.

