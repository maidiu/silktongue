import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const quizFilePath = path.join(__dirname, '../../weekly_quizzes/2025.10.25_quiz.json');

// Expanded red herrings that match the length/style of real answers
const expandedRedHerrings = {
  lumbering: [
    "He was carried by Crusader caravans—where lumbering beasts hauled siege engines across desolate landscapes toward the walls of holy cities. Chroniclers wrote of how the massive engines lumbered forward like moving fortresses, shaking the earth with their advance. The word became synonymous with the slow, inexorable march of holy war—weight transformed into divine purpose. What moved slowly moved with God's will, and could not be stopped.",
    "He became the rhythm of Renaissance warehouses—where Italian merchants lumbered goods from ship to stall in chaotic loading docks. The sound of heavy crates being lumbered through narrow passages echoed through Mediterranean ports. Commerce moved in bulk, not grace—barrels and bales that bent the backs of porters. The merchant's profit lived in volume, and volume demanded the lumbering gait.",
    "He symbolized the heroic burden of explorers who lumbered through unmapped wilderness—bearing impossible loads of supplies and equipment into unknown territories, where every step was a conquest of distance and weight. Discovery was not swift but deliberate, measured in the ache of muscles and the slow accumulation of miles. The explorers who lumbered furthest carried the heaviest loads—civilization itself on their backs."
  ],
  pall: [
    "He was woven by Carolingian nuns as the veil for relics—where the sacred cloth shielded mortal remains from mortal sight, creating a boundary between the temporal and eternal. In monastery scriptoria, he represented the mystery of what lives beyond the body. The pall became a threshold: on one side, the corrupting flesh; on the other, the incorruptible saint. To lift it was to witness transformation itself.",
    "He became the standard of Crusader knights—where black silk marked the deathless crusade against infidel lands, transforming personal grief into divine mission. Chroniclers recorded how he flew over battlefields as both promise and memorial. The pall that covered the dead became the banner of the living—sorrow weaponized, loss made militant. What mourned also marched.",
    "He symbolized the Romantic shroud of melancholy that covered the artist's soul—making sorrow into aesthetic beauty, where creative genius found its voice in the language of loss and longing that could not be expressed in cheer. The poets wore their palls proudly: darkness as distinction, gloom as depth. The pall that once hid death now revealed the artist's sensitive heart."
  ],
  scurry: [
    "He was carried by minstrels scurrying through medieval castles—where performers rushed between courts seeking patronage, their hurrying feet carrying songs and stories from one great hall to the next in the perpetual dance of courtly service. The minstrel's scurry was survival: to arrive late was to lose the feast, to linger too long was to wear out welcome. Entertainment moved at the pace of anxiety.",
    "He became the secret language of spies scurrying through Renaissance cities—gathering intelligence in the shadows of power, where every hurried movement carried the weight of state secrets and political survival. In Venice, in Florence, in Rome, the spy who scurried survived; the spy who strutted died. Information moved on quick feet, and those feet left no memorable trail.",
    "He symbolized the enlightened citizen scurrying between coffee houses and salons—where ideas traveled faster than people, and the new public sphere was built on the hurried circulation of printed words and spoken debate. To scurry from salon to salon was to participate in modernity itself—the rapid exchange that built democracy one conversation at a time."
  ],
  steadfast: [
    "He was sworn by Viking jarls who held fast to their word across seas and seasons—where honor was measured by constancy in the face of betrayal, and the steadfast heart was the only currency that survived changing alliances. In the sagas, the steadfast warrior outlived the bold one: not by strength but by endurance, not by victory but by never turning aside. The oath spoken steadfastly was the oath the gods remembered.",
    "He became the creed of Crusader knights who stood steadfast before infidel armies—where faith in God became unbreakable resolve, and the steadfast heart found its true test not in victory but in remaining true when all hope had fled. The Crusader who stood steadfast in defeat earned more honor than the one who fled in victory. To hold the line when the line broke—that was the word's highest meaning.",
    "He symbolized the enlightened philosopher's commitment to reason—where steadfast pursuit of truth outweighed all worldly pressures, and intellectual integrity became the highest form of courage in an age of questioning. To stand steadfast for reason was to stand alone: against tradition, against authority, against comfort itself. The philosopher's steadfastness demanded social sacrifice for intellectual honesty."
  ]
};

async function expandWeek2RedHerrings() {
  console.log('🔄 Expanding red herrings for lumbering, pall, scurry, steadfast...\n');
  
  const quizData = JSON.parse(fs.readFileSync(quizFilePath, 'utf8'));
  let changesMade = 0;
  
  const updatedQuizData = quizData.map(quiz => {
    if (quiz.level === 6 && expandedRedHerrings[quiz.word]) {
      console.log(`✓ Expanding red herrings for ${quiz.word}`);
      const expanded = expandedRedHerrings[quiz.word];
      
      // Update the red_herrings array with expanded versions
      quiz.options.red_herrings = expanded;
      
      // Also update the short false turns in the turns array (last 3 entries)
      const realTurns = quiz.options.turns.slice(0, 4); // Keep first 4 (real ones)
      
      // Create short versions for the turns array (first ~2 sentences)
      const shortFalseTurns = expanded.map(turn => {
        const firstTwoSentences = turn.split('. ').slice(0, 2).join('. ') + '.';
        return firstTwoSentences;
      });
      
      quiz.options.turns = [...realTurns, ...shortFalseTurns];
      
      console.log(`  - Expanded ${expanded.length} red herrings to full length`);
      console.log(`  - Average red herring length: ${Math.round(expanded.reduce((sum, h) => sum + h.length, 0) / expanded.length)} chars`);
      console.log(`  - Average real turn length: ${Math.round(realTurns.reduce((sum, t) => sum + t.length, 0) / realTurns.length)} chars\n`);
      
      changesMade++;
    }
    return quiz;
  });
  
  if (changesMade > 0) {
    fs.writeFileSync(quizFilePath, JSON.stringify(updatedQuizData, null, 2), 'utf8');
    console.log(`✅ Expanded red herrings for ${changesMade} words`);
  }
}

expandWeek2RedHerrings();

