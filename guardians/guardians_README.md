Project Overview: The Tower (Silksong Lexicon Mode)

We’re building a narrative framework that teaches vocabulary through mythic storytelling. Each “floor” of the Tower corresponds to a week’s word list.

Each floor contains:

A guardian (a distinct voice or archetype of language — the Mason, the Jurist, the Poet, etc.).

A short intro paragraph that establishes tone and setting.

A series of eight paragraphs, one per vocabulary word.

Each paragraph is a moment in the guardian’s monologue where he’s telling a story and circling around a word he can’t remember.

The player learns or recalls the correct word by inference.

When all eight words are restored, the guardian’s story resolves, and the staircase to the next floor opens.

The tone follows the Silksong Lexicon parameters: restrained, mythic, precise, slightly haunted — “quietly mythic, like an old bell still ringing in fog.”

File Structure (JSON Schema Example)

Each floor is stored as a JSON object with:

{
  "floor": 1,
  "guardian": "The Mason",
  "intro": "Intro paragraph setting the scene.",
  "dialogue": [
    {
      "order": 1,
      "word": "impede",
      "paragraph": "The guardian's speech leading up to that word."
    }
    // ... eight total
  ],
  "completion": "Short closing description that triggers after all words are found."
}


This structure allows for:

Modular generation or editing of new floors.

Automatic rendering of dialogue or voice lines in the game engine.

Progressive unlocking based on word completion.

Narrative Logic

The Tower is the spine story. Each guardian tells a fragment of its myth, but none can complete it.

The missing words are what keep them trapped on their floors.

Every floor represents a different register of language — craft, law, story, poetry, bureaucracy, machine, etc.

The player ascends by restoring language itself — each recovered word reconstitutes part of the Tower’s memory.

Week Integration

Each week’s vocab set (8 words) automatically populates a floor. The system doesn’t require thematic alignment — the guardian’s dialogue absorbs the words naturally into his speech.
The JSON provides a flexible format for:

procedural narrative generation,

vocabulary-based gameplay loops,

or export into an app or lesson interface.