

# **Silksong Lexicon — Full Generation Protocol**

### **1\. Canonical Schema**

* Every entry must validate against **2025.10.17.json**.

* Field names, nesting, and order are fixed.

* No nulls; omit unused fields.

* Each file is an array of full word objects.

* Required fields:  
   `word`, `part_of_speech`, `modern_definition`, `usage_example`, `synonyms`, `antonyms`, `related`,  
   `french_equivalent`, `russian_equivalent`, `definitions`, `variant_forms`, `semantic_field`,  
   `french_synonyms`, `french_root_cognates`, `russian_synonyms`, `russian_root_cognates`,  
   `common_collocations`, `story_intro`, `story[]`, `why_the_shifts_happened`,  
   `common_phrases`, `structural_analysis`, `cefr_level`, `frequency_band`, `date_added`.

---

### **2\. Purpose**

Generate entries that **teach verified etymology and semantic history** through **narrative embodiment**.  
 The word must feel alive—its factual evolution told as psychological and historical drama.  
 Truth is the skeleton; tone and emotion give it life.

---

### **3\. Data Gathering**

When a word is provided:

1. Pull attested roots, meanings, and earliest forms from trusted sources (OED, Etymonline, Wiktionary, CNRTL, academic lexica).

2. Identify transmission path (Latin → Old French → English, etc.).

3. Mark all major semantic or contextual inflection points (2 – 6).

4. Record the cultural, political, theological, or technological environments that coincide with each shift.

5. Note derivative and sibling forms for later reference.

---

### **4\. Story Construction**

#### **A. story\_intro**

* 40–80 words.

* Present tense.

* Describe the word as a living being in its current form.

* Tone: restrained, atmospheric, precise.

* Establish the emotional and thematic center of its journey.

#### **B. story (array)**

* One element per **attested or strongly inferable** inflection point (60–110 words).

* 2 – 6 total, depending on real evidence.

* Each includes:

  * `century`

  * `story_text`

  * `sibling_words`

  * `context`

  * `causal_tags`

* Writing method:

  * Base every shift on factual linguistic change.

  * Frame each era as one stage of the same consciousness.

  * When cause is uncertain, use narrative inference with clear humility:  
     *“Records fade here, but something in the new age bent him toward …”*

  * Ellipsis and silence can stand for missing data—never invent false detail.

#### **C. why\_the\_shifts\_happened**

* 3–5 bullet points summarizing factual macro movements.

* Concise, objective phrasing.

---

### **5\. Evidence Discipline**

* Each claim must trace to attested linguistic or historical data.

* Mark speculative reasoning through phrasing, not disclaimers.

* No anachronism or invented intermediaries.

* If evidence is sparse, compress the passage and maintain transparency.

---

### **6\. Tone Determination Rule**

**Tone is set by the nature of the shift, not the era itself.**

* Emotional color reflects what the word *experienced*—how it was used, what pressure it bore.

* The historical setting supplies tension, not automatic mood.

Tone \= (psychological truth of the shift) × (emotional pressure of its environment)

**Examples**

* Word gaining strength under repression → defiant, coded, resilient.

* Word moralized into constraint → pious, uneasy.

* Word emptied by systemization → mechanical, weary.

* Word revived by revolt or art → luminous, expansive.

* Word finding rest after trauma → reflective, grounded.

Never assign tone by century; derive it from the lived semantic event.

### **6A. Biographical-Psychological Tone Framework**

**Core Premise**  
 Each word functions as a **personality shaped by experience.**  
 Its meaning is its temperament; its semantic shifts are the events and pressures that modify that temperament.  
 The story’s tone must reflect what the word *underwent*—not only what changed linguistically, but what that change would *feel like* if meaning were a life.

**Method**

1. **Start from the word’s root essence.**

   * Ask: *What kind of being would this word be if its first meaning were its character?*

     * *impede* → deliberate, resistant, physical.

     * *faith* → trusting, forward-leaning, vulnerable.

     * *gay* → joyful, expressive, unguarded.

2. **Read each semantic shift as a formative event.**

   * Expansion → exposure or awakening.

   * Narrowing → wound or specialization.

   * Moralization → internal conflict, conscience, repression.

   * Reappropriation → self-defense, pride, rebirth.

3. **Derive tone from the interaction** between the word’s core temperament and its new environment.

   * When the world affirms its nature → confident, open, radiant.

   * When the world distorts or punishes it → wary, coded, defensive.

   * When the world forgets it → ghostly, nostalgic, withdrawn.

4. **Maintain psychological continuity.**

   * The word is always recognizably the same being; only its coping mechanisms evolve.

   * Later stages should carry emotional residue from earlier ones (guilt, irony, serenity, fatigue, etc.).

5. **Spiritual realism.**

   * Treat moral and emotional reactions as plausibly human.

   * A word can mature, repress, rebel, forgive, or transcend—but not behave arbitrarily.

   * The tone should make sense as the inner life of its semantics.

**Result**  
 Each entry reads as a **credible biography**: a single consciousness enduring the pressures of history, changing form while retaining a trace of its origin.

---

### **7\. Style Rules**

* Short-to-medium sentences, clear rhythm.

* Imagery must come from the root metaphor (*bind*, *shine*, *move*, *grow*, *fall*).

* No jargon or academic analysis inside `story_text`.

* Emotional authenticity over flourish.

* Each story segment should read as a scene or mood, not an essay.

* Show moral or social change through context, not commentary.

---

### **8\. Structural Analysis**

Each entry ends with one paragraph (40–70 words) that unites **fact and psychology**.

It must:

1. Summarize how form, meaning, and social context converged.

2. Portray the word as a psyche shaped by those experiences.

3. Conclude with what the word has “become” — emotionally and conceptually — by the present.

4. Stay consistent with historical truth.

Example model:

“He was born joy itself, learned disguise under judgment, and now lives as light that knows its cost.”

---

### **9\. Causal Tags**

Use tags only from the approved list.  
 Each tag must reflect an observable linguistic process:

lexical\_origin, borrowing\_contact, calque, sound\_change,

morphological\_derivation, semantic\_narrowing, semantic\_broadening,

pejoration, amelioration, metaphorization, metonymy,

moralization, bureaucratization, technological\_context,

colloquial\_extension, register\_shift, reappropriation,

taboo\_euphemism\_cycle, semantic\_bleaching, ironic\_inversion,

internet\_meme\_vehiculation, youth\_slang\_cycle, prestige\_loan,

diaspora\_loop, semantic\_neutralization, semantic\_stabilization,

language\_transition, industrial\_context, scientific\_context,

philosophical\_extension, sociological\_context,

humanist\_reinterpretation, spiritual\_shift, discursive\_divergence,

structural\_shift, political\_context

---

### **10\. CEFR Calibration**

* **B2:** clear syntax, minimal imagery.

* **C1:** layered imagery, moderate abstraction.

* **C2:** complex rhythm, philosophical nuance.  
   Language level affects prose texture only, not factual density.

---

### **11\. Validation Checklist**

Before finalizing an entry:

1. Verify chronological order.

2. Confirm each story item corresponds to a real shift.

3. Ensure causal tags match content.

4. Check CEFR and length ranges.

5. Confirm `structural_analysis` integrates factual summary \+ psychological portrait.

6. Lint JSON for syntax correctness.

---

### **12\. Generator Priorities**

1. **Accuracy** — historically and linguistically verifiable.

2. **Continuity** — one coherent consciousness through time.

3. **Clarity** — pedagogically readable.

4. **Atmosphere** — consistent restrained tone.

5. **Emotional resonance** — understanding the human cost of meaning change.

---

### **13\. Edge Cases**

* **Slang / internet terms:** use real origin path and cultural setting; apply tags like `internet_meme_vehiculation`, `reappropriation`, `youth_slang_cycle`.

* **Non-Indo-European borrowings:** trace verified contact routes.

* **Stable words:** emphasize endurance—why it resisted change.

---

### **14\. Output Requirements**

* You provide the word list.

* Each produced file (e.g., `YYYY.MM.DD.json`) contains 6 – 8 entries.

* Each entry totals ≈ 400–650 words.

* Punctuation plain (no smart quotes).

* JSON must lint cleanly.

---

### **15\. Guiding Principle**

**Etymology \= skeleton**  
 **History \= muscle**  
 **Psychology \= face**

Each word must emerge **true and alive**—verified in data, coherent in feeling, precise in craft.

---

**End of Protocol**

