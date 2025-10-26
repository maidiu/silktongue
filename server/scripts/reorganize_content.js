import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read all existing content files
const weeklyEntriesPath = path.join(__dirname, '../../weekly_entries/2025.10.17.json');
const level5QuizzesPath = path.join(__dirname, '../../weekly_quizzes/level5_quizzes.json');
const level6QuizzesPath = path.join(__dirname, '../../weekly_quizzes/level6_quizzes.json');

// Read the files
const vocabularyEntries = JSON.parse(fs.readFileSync(weeklyEntriesPath, 'utf8'));
const level5Quizzes = JSON.parse(fs.readFileSync(level5QuizzesPath, 'utf8'));
const level6Quizzes = JSON.parse(fs.readFileSync(level6QuizzesPath, 'utf8'));

// Create comprehensive content structure
const comprehensiveContent = {
  "metadata": {
    "batch_date": "2025.10.17",
    "created_at": "2025-10-17T00:00:00Z",
    "description": "First batch of 8 vocabulary words with complete content including stories, quizzes, and comprehension questions",
    "words_count": vocabularyEntries.length,
    "cefr_levels": [...new Set(vocabularyEntries.map(entry => entry.cefr_level))],
    "content_types": ["vocabulary_entries", "quiz_materials", "story_comprehension_questions"],
    "version": "1.0"
  },
  "vocabulary_entries": vocabularyEntries,
  "quiz_materials": {
    "level_1_spelling": vocabularyEntries.map(entry => ({
      "word": entry.word,
      "level": 1,
      "question_type": "spelling",
      "prompt": `Spell the word '${entry.word}'`,
      "correct_answer": entry.word,
      "reward_amount": 5,
      "difficulty": "easy"
    })),
    "level_2_typing": vocabularyEntries.map(entry => ({
      "word": entry.word,
      "level": 2,
      "question_type": "typing",
      "prompt": `Type the word '${entry.word}'`,
      "correct_answer": entry.word,
      "reward_amount": 8,
      "difficulty": "easy"
    })),
    "level_3_definition": vocabularyEntries.map(entry => ({
      "word": entry.word,
      "level": 3,
      "question_type": "definition",
      "prompt": `What does '${entry.word}' mean?`,
      "options": {
        "incorrect_answers": entry.antonyms.slice(0, 3),
        "correct_answers": [entry.modern_definition]
      },
      "correct_answer": entry.modern_definition,
      "reward_amount": 12,
      "difficulty": "medium"
    })),
    "level_4_synonym": vocabularyEntries.map(entry => ({
      "word": entry.word,
      "level": 4,
      "question_type": "synonym",
      "prompt": `Select the synonyms of '${entry.word}'`,
      "options": {
        "synonyms": entry.synonyms,
        "antonyms": entry.antonyms,
        "red_herrings": entry.antonyms.slice(0, 4)
      },
      "correct_answer": entry.synonyms,
      "reward_amount": 15,
      "difficulty": "medium"
    })),
    "level_5_story": level5Quizzes,
    "level_6_beast_mode": level6Quizzes
  },
  "story_comprehension_questions": [
    {
      "word": "impede",
      "word_id": 1,
      "questions": [
        {
          "century": "1",
          "question": "What sphere was responsible for Impede's original meaning in ancient Rome?",
          "options": ["Military", "Religion", "Medicine", "Agriculture"],
          "correct_answer": "Military",
          "explanation": "The text mentions soldiers feeling Impede in their tangled nets and lawyers in petitions, indicating military and legal contexts."
        },
        {
          "century": "14",
          "question": "What caused Impede's meaning to shift in the 14th century?",
          "options": ["Industrial Revolution", "Feudal Christianity", "Renaissance Art", "Scientific Method"],
          "correct_answer": "Feudal Christianity",
          "explanation": "The text states that 'prayers replaced campaigns' and Impede became 'the enemy of grace' in sermons, showing religious moralization."
        },
        {
          "century": "16",
          "question": "What cultural movement transformed Impede from evil to inconvenient?",
          "options": ["The Renaissance", "The Enlightenment", "The Reformation", "The Industrial Revolution"],
          "correct_answer": "The Renaissance",
          "explanation": "The text explicitly states 'Then the Renaissance arrived' and describes how 'motion itself became a metaphor' for discovery and progress."
        },
        {
          "century": "19",
          "question": "What type of systems did Impede haunt in the industrial age?",
          "options": ["Religious", "Military", "Mechanical", "Agricultural"],
          "correct_answer": "Mechanical",
          "explanation": "The text states Impede 'haunted the gears of systems' and 'What began in the body ended in the machine,' indicating mechanical systems."
        }
      ]
    },
    {
      "word": "inherent",
      "word_id": 2,
      "questions": [
        {
          "century": "1",
          "question": "What philosophical concept was Inherent originally associated with in Rome?",
          "options": ["Motion", "Substance", "Time", "Space"],
          "correct_answer": "Substance",
          "explanation": "The text mentions 'substance' and 'what belonged to the thing itself,' indicating Aristotelian substance philosophy."
        },
        {
          "century": "14",
          "question": "What medieval institution used Inherent to distinguish natural from supernatural?",
          "options": ["The Military", "The Church", "The University", "The Guild"],
          "correct_answer": "The Church",
          "explanation": "The text states 'Scholastic theologians' used it to distinguish 'natural properties from divine gifts,' indicating Church theology."
        },
        {
          "century": "17",
          "question": "What scientific revolution made Inherent crucial for distinguishing properties?",
          "options": ["The Copernican Revolution", "The Scientific Revolution", "The Industrial Revolution", "The Digital Revolution"],
          "correct_answer": "The Scientific Revolution",
          "explanation": "The text mentions 'scientific method' and 'distinguishing essential from accidental properties,' indicating the Scientific Revolution."
        },
        {
          "century": "19",
          "question": "What field of study made Inherent central to understanding natural laws?",
          "options": ["Literature", "Biology", "Physics", "Psychology"],
          "correct_answer": "Physics",
          "explanation": "The text states 'natural laws' and 'what belonged to matter itself,' indicating physics and natural science."
        }
      ]
    },
    {
      "word": "cohesive",
      "word_id": 3,
      "questions": [
        {
          "century": "1",
          "question": "What physical property did Cohesive originally describe in Rome?",
          "options": ["Color", "Stickiness", "Weight", "Temperature"],
          "correct_answer": "Stickiness",
          "explanation": "The text mentions 'glue' and 'what held things together,' indicating stickiness and adhesion."
        },
        {
          "century": "14",
          "question": "What medieval institution used Cohesive to describe spiritual unity?",
          "options": ["The Military", "The Church", "The University", "The Court"],
          "correct_answer": "The Church",
          "explanation": "The text states 'Church Fathers' used it for 'the unity of the faithful' and 'spiritual bonds,' indicating Church theology."
        },
        {
          "century": "17",
          "question": "What scientific field made Cohesive important for understanding matter?",
          "options": ["Astronomy", "Chemistry", "Medicine", "Mathematics"],
          "correct_answer": "Chemistry",
          "explanation": "The text mentions 'chemical bonds' and 'what held molecules together,' indicating chemistry."
        },
        {
          "century": "19",
          "question": "What social movement used Cohesive to describe group unity?",
          "options": ["Nationalism", "Individualism", "Capitalism", "Socialism"],
          "correct_answer": "Nationalism",
          "explanation": "The text states 'national unity' and 'what bound societies together,' indicating nationalism."
        }
      ]
    },
    {
      "word": "scattershot",
      "word_id": 4,
      "questions": [
        {
          "century": "1",
          "question": "What military context gave Scattershot its original meaning?",
          "options": ["Naval Warfare", "Siege Warfare", "Cavalry Charges", "Archery"],
          "correct_answer": "Archery",
          "explanation": "The text mentions 'archers' and 'scattered arrows,' indicating archery and ranged combat."
        },
        {
          "century": "14",
          "question": "What medieval practice made Scattershot describe ineffective effort?",
          "options": ["Farming", "Hunting", "Fishing", "Trading"],
          "correct_answer": "Hunting",
          "explanation": "The text mentions 'hunters' and 'scattered shots' that 'missed their mark,' indicating hunting."
        },
        {
          "century": "17",
          "question": "What military development made Scattershot describe random firing?",
          "options": ["Cannons", "Muskets", "Swords", "Shields"],
          "correct_answer": "Muskets",
          "explanation": "The text mentions 'muskets' and 'random firing,' indicating early firearms."
        },
        {
          "century": "19",
          "question": "What social context made Scattershot describe unfocused action?",
          "options": ["Education", "Industry", "Religion", "Politics"],
          "correct_answer": "Industry",
          "explanation": "The text mentions 'industrial efficiency' and 'unfocused effort,' indicating industrial context."
        }
      ]
    },
    {
      "word": "salient",
      "word_id": 5,
      "questions": [
        {
          "century": "1",
          "question": "What physical property did Salient originally describe in Rome?",
          "options": ["Jumping", "Running", "Swimming", "Flying"],
          "correct_answer": "Jumping",
          "explanation": "The text mentions 'leaping' and 'jumping forward,' indicating jumping motion."
        },
        {
          "century": "14",
          "question": "What medieval institution used Salient to describe prominent features?",
          "options": ["The Military", "The Church", "The University", "The Guild"],
          "correct_answer": "The Church",
          "explanation": "The text mentions 'Church architecture' and 'prominent features,' indicating Church buildings."
        },
        {
          "century": "17",
          "question": "What scientific field made Salient important for describing prominent features?",
          "options": ["Astronomy", "Biology", "Chemistry", "Mathematics"],
          "correct_answer": "Biology",
          "explanation": "The text mentions 'natural history' and 'prominent features of plants and animals,' indicating biology."
        },
        {
          "century": "19",
          "question": "What social movement used Salient to describe important points?",
          "options": ["Romanticism", "Realism", "Modernism", "Postmodernism"],
          "correct_answer": "Realism",
          "explanation": "The text mentions 'realist literature' and 'important points,' indicating realism."
        }
      ]
    },
    {
      "word": "omit",
      "word_id": 6,
      "questions": [
        {
          "century": "1",
          "question": "What activity did Omit originally describe in Rome?",
          "options": ["Writing", "Speaking", "Reading", "Listening"],
          "correct_answer": "Writing",
          "explanation": "The text mentions 'scribes' and 'leaving out words,' indicating writing and transcription."
        },
        {
          "century": "14",
          "question": "What medieval practice made Omit describe leaving out information?",
          "options": ["Farming", "Hunting", "Copying", "Trading"],
          "correct_answer": "Copying",
          "explanation": "The text mentions 'monks copying texts' and 'leaving out words,' indicating manuscript copying."
        },
        {
          "century": "17",
          "question": "What literary development made Omit important for editing?",
          "options": ["Poetry", "Drama", "The Novel", "The Essay"],
          "correct_answer": "The Novel",
          "explanation": "The text mentions 'novelists' and 'editing,' indicating the rise of the novel."
        },
        {
          "century": "19",
          "question": "What social context made Omit describe leaving out details?",
          "options": ["Education", "Industry", "Religion", "Politics"],
          "correct_answer": "Politics",
          "explanation": "The text mentions 'political discourse' and 'leaving out details,' indicating politics."
        }
      ]
    },
    {
      "word": "perfunctory",
      "word_id": 7,
      "questions": [
        {
          "century": "1",
          "question": "What activity did Perfunctory originally describe in Rome?",
          "options": ["Writing", "Speaking", "Reading", "Listening"],
          "correct_answer": "Speaking",
          "explanation": "The text mentions 'orators' and 'going through the motions,' indicating public speaking."
        },
        {
          "century": "14",
          "question": "What medieval institution used Perfunctory to describe ritual performance?",
          "options": ["The Military", "The Church", "The University", "The Guild"],
          "correct_answer": "The Church",
          "explanation": "The text mentions 'Church rituals' and 'going through the motions,' indicating Church ceremonies."
        },
        {
          "century": "17",
          "question": "What social development made Perfunctory describe routine tasks?",
          "options": ["Education", "Industry", "Religion", "Politics"],
          "correct_answer": "Industry",
          "explanation": "The text mentions 'industrial work' and 'routine tasks,' indicating industrial context."
        },
        {
          "century": "19",
          "question": "What social context made Perfunctory describe superficial effort?",
          "options": ["Education", "Industry", "Religion", "Politics"],
          "correct_answer": "Education",
          "explanation": "The text mentions 'education' and 'superficial effort,' indicating educational context."
        }
      ]
    },
    {
      "word": "verisimilitude",
      "word_id": 8,
      "questions": [
        {
          "century": "1",
          "question": "What field of study gave Verisimilitude its original meaning in Rome?",
          "options": ["Medicine", "Philosophy", "Military", "Agriculture"],
          "correct_answer": "Philosophy",
          "explanation": "The text mentions 'Philosophers' and 'Cicero' and 'the orator's art,' indicating philosophy and rhetoric."
        },
        {
          "century": "14",
          "question": "What medieval practice made Verisimilitude important for storytelling?",
          "options": ["Farming", "Hunting", "Copying", "Trading"],
          "correct_answer": "Copying",
          "explanation": "The text mentions 'Medieval scholars' and 'Arabic translations' and 'the soul of narrative,' indicating manuscript copying and scholarship."
        },
        {
          "century": "17",
          "question": "What literary development made Verisimilitude central to English literature?",
          "options": ["Poetry", "Drama", "The Novel", "The Essay"],
          "correct_answer": "The Novel",
          "explanation": "The text mentions 'Defoe and Richardson' and 'the rise of the novel,' indicating the novel's development."
        },
        {
          "century": "19",
          "question": "What literary movement made Verisimilitude demanding and scientific?",
          "options": ["Romanticism", "Realism", "Modernism", "Postmodernism"],
          "correct_answer": "Realism",
          "explanation": "The text mentions 'The realists' and 'Flaubert, Tolstoy, Eliot' and 'documentary accuracy,' indicating realism."
        },
        {
          "century": "20",
          "question": "What new field of study used Verisimilitude for evidence evaluation?",
          "options": ["Literature", "Law", "Science", "Art"],
          "correct_answer": "Law",
          "explanation": "The text mentions 'courtrooms' and 'forensic verisimilitude' and 'the story that fits the evidence,' indicating legal theory."
        },
        {
          "century": "21",
          "question": "What technological development made Verisimilitude an engineering challenge?",
          "options": ["Printing", "Photography", "Digital Media", "Transportation"],
          "correct_answer": "Digital Media",
          "explanation": "The text mentions 'deepfakes and virtual worlds' and 'algorithms that predict believability,' indicating digital media."
        }
      ]
    }
  ]
};

// Write the comprehensive content to the organized structure
const outputPath = path.join(__dirname, '../../content/2025.10.17/complete_content.json');
fs.writeFileSync(outputPath, JSON.stringify(comprehensiveContent, null, 2));

console.log('✅ Comprehensive content organized successfully!');
console.log(`📁 Output: ${outputPath}`);
console.log(`📊 Words: ${vocabularyEntries.length}`);
console.log(`📚 Quiz levels: 6 (spelling, typing, definition, synonym, story, beast mode)`);
console.log(`🧠 Story questions: ${comprehensiveContent.story_comprehension_questions.reduce((total, word) => total + word.questions.length, 0)}`);

// Create individual files for each content type
const individualFiles = {
  'vocabulary_entries.json': comprehensiveContent.vocabulary_entries,
  'quiz_materials.json': comprehensiveContent.quiz_materials,
  'story_comprehension_questions.json': comprehensiveContent.story_comprehension_questions
};

for (const [filename, content] of Object.entries(individualFiles)) {
  const filePath = path.join(__dirname, '../../content/2025.10.17', filename);
  fs.writeFileSync(filePath, JSON.stringify(content, null, 2));
  console.log(`📄 Created: ${filename}`);
}

console.log('\n🎉 All content has been reorganized by date!');
console.log('📁 Structure:');
console.log('   content/');
console.log('   └── 2025.10.17/');
console.log('       ├── complete_content.json (everything together)');
console.log('       ├── vocabulary_entries.json');
console.log('       ├── quiz_materials.json');
console.log('       └── story_comprehension_questions.json');
