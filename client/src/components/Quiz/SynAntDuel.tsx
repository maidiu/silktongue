import { useState, useEffect } from 'react';
import { DndContext, useSensor, useSensors, PointerSensor, TouchSensor, useDraggable, useDroppable } from '@dnd-kit/core';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';

interface SynAntDuelProps {
  synonyms: string[];
  antonyms: string[];
  redHerrings?: string[];
  minCorrectToPass?: number;
  onSuccess?: () => void;
  onFail?: () => void;
}

function DraggableWord({ id, word, zone }: { id: string; word: string; zone: string | null }) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({ id });

  const style = transform ? {
    transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
  } : undefined;

  return (
    <motion.div
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: isDragging ? 0.5 : 1, scale: 1 }}
      className={`
        px-5 py-3 sm:px-4 sm:py-2 
        rounded cursor-grab active:cursor-grabbing
        select-none font-display transition-all duration-200
        text-base sm:text-sm
        touch-none
        min-h-[48px] sm:min-h-[auto]
        flex items-center justify-center
        ${zone === null ? 'bg-gray-800/80 text-gray-200 border-2 border-gray-700' : ''}
        ${zone === 'synonyms' ? 'bg-blue-900/40 text-blue-200 border-2 border-blue-600/50' : ''}
        ${zone === 'antonyms' ? 'bg-orange-900/40 text-orange-200 border-2 border-orange-600/50' : ''}
      `}
    >
      {word}
    </motion.div>
  );
}

function DropZone({ id, title, children }: { id: string; title: string; children: React.ReactNode }) {
  const { setNodeRef, isOver } = useDroppable({ id });

  return (
    <div
      ref={setNodeRef}
      className={`
        flex-1 min-h-[300px] p-6 rounded border-2 transition-all duration-300
        ${isOver ? 'border-white/60 bg-white/10' : 'border-gray-700 bg-gray-900/40'}
      `}
    >
      <h3 className="text-xl font-display font-bold text-center mb-4 text-white">
        {title}
      </h3>
      <div className="flex flex-wrap gap-3 justify-center">
        {children}
      </div>
    </div>
  );
}

export default function SynAntDuel({
  synonyms,
  antonyms,
  redHerrings = [],
  minCorrectToPass = 6,
  onSuccess,
  onFail
}: SynAntDuelProps) {
  const [wordStates, setWordStates] = useState<Map<string, string | null>>(new Map());
  const [allWords, setAllWords] = useState<string[]>([]);
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState<'correct' | 'wrong' | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 3,
      },
    }),
    useSensor(TouchSensor, {
      activationConstraint: {
        delay: 0, // Instant response - no delay!
        tolerance: 3,
      },
    })
  );

  useEffect(() => {
    // Combine and shuffle all words
    const combined = [...synonyms, ...antonyms, ...redHerrings];
    // Use a more robust shuffle algorithm (Fisher-Yates)
    const shuffled = [...combined];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    setAllWords(shuffled);
    
    // Initialize all words in null zone (unsorted)
    const initialStates = new Map<string, string | null>();
    shuffled.forEach(word => initialStates.set(word, null));
    setWordStates(initialStates);
  }, [synonyms, antonyms, redHerrings]);

  const handleDragEnd = (event: any) => {
    const { active, over } = event;
    if (!over) return;

    const word = active.id as string;
    const zone = over.id as string;

    setWordStates(prev => {
      const next = new Map(prev);
      next.set(word, zone === 'unsorted' ? null : zone);
      return next;
    });
  };

  const handleSubmit = () => {
    setSubmitted(true);
    
    let correctCount = 0;
    
    wordStates.forEach((zone, word) => {
      if (zone === 'synonyms' && synonyms.includes(word)) correctCount++;
      if (zone === 'antonyms' && antonyms.includes(word)) correctCount++;
    });
    
    const passed = correctCount >= minCorrectToPass;
    setResult(passed ? 'correct' : 'wrong');
    
    setTimeout(() => {
      if (passed && onSuccess) {
        onSuccess();
      } else if (!passed && onFail) {
        onFail();
        // Reset
        setTimeout(() => {
          const initialStates = new Map<string, string | null>();
          allWords.forEach(word => initialStates.set(word, null));
          setWordStates(initialStates);
          setSubmitted(false);
          setResult(null);
        }, 2000);
      }
    }, 1500);
  };

  const getWordsInZone = (zone: string | null) => {
    return allWords.filter(word => wordStates.get(word) === zone);
  };

  return (
    <LevelScene
      title="IV. Relation — Connection"
      instruction="Draw words toward or away: synonyms to the left, antonyms to the right."
    >
      <div className="flex flex-col items-center mt-8 gap-6">
        <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
          <div className="flex gap-6 w-full max-w-5xl mb-6">
            <DropZone id="synonyms" title="Draw Near">
              {getWordsInZone('synonyms').map(word => (
                <DraggableWord key={word} id={word} word={word} zone="synonyms" />
              ))}
            </DropZone>

            <DropZone id="antonyms" title="Repel">
              {getWordsInZone('antonyms').map(word => (
                <DraggableWord key={word} id={word} word={word} zone="antonyms" />
              ))}
            </DropZone>
          </div>

          {/* Unsorted zone */}
          <div
            className="w-full max-w-5xl p-6 rounded border-2 border-dashed border-gray-700 bg-gray-900/20"
          >
            <h3 className="text-lg font-display text-center mb-4 text-gray-400">
              Words to Sort
            </h3>
            <div className="flex flex-wrap gap-3 justify-center">
              {getWordsInZone(null).map(word => (
                <DraggableWord key={word} id={word} word={word} zone={null} />
              ))}
            </div>
          </div>
        </DndContext>

        {!submitted && getWordsInZone(null).length === 0 && (
          <motion.button
            onClick={handleSubmit}
            className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30
                     hover:bg-white/20 hover:border-white/50 transition-all duration-300
                     font-display uppercase tracking-wider"
          >
            Submit
          </motion.button>
        )}

        {result && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            {result === 'correct' ? (
              <div className="text-white text-xl font-display">
                ✓ You have sorted truth from opposition
              </div>
            ) : (
              <div className="text-red-400 text-xl font-display">
                ✗ Some words landed in the wrong place
              </div>
            )}
          </motion.div>
        )}
      </div>
    </LevelScene>
  );
}

