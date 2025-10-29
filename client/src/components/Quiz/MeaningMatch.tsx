import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';

interface MeaningMatchProps {
  options: string[];
  correctAnswers: string[];
  minCorrectToPass?: number;
  onSuccess?: () => void;
  onFail?: () => void;
}

export default function MeaningMatch({ 
  options, 
  correctAnswers, 
  minCorrectToPass = 3,
  onSuccess, 
  onFail 
}: MeaningMatchProps) {
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [submitted, setSubmitted] = useState(false);
  const [shuffledOptions, setShuffledOptions] = useState<string[]>([]);

  useEffect(() => {
    // Shuffle options on mount
    setShuffledOptions([...options].sort(() => Math.random() - 0.5));
  }, [options]);

  const toggleSelection = (option: string) => {
    if (submitted) return;
    
    const newSelected = new Set(selected);
    if (newSelected.has(option)) {
      newSelected.delete(option);
    } else {
      newSelected.add(option);
    }
    setSelected(newSelected);
  };

  const handleSubmit = () => {
    setSubmitted(true);
    
    // Count correct selections
    const correctCount = [...selected].filter(s => correctAnswers.includes(s)).length;
    const incorrectCount = [...selected].filter(s => !correctAnswers.includes(s)).length;
    
    const passed = correctCount >= minCorrectToPass && incorrectCount === 0;
    
    console.log('MeaningMatch Debug:', {
      selected: [...selected],
      correctAnswers,
      correctCount,
      incorrectCount,
      minCorrectToPass,
      passed
    });
    
    setTimeout(() => {
      if (passed && onSuccess) {
        console.log('Calling onSuccess');
        onSuccess();
      } else if (!passed && onFail) {
        console.log('Calling onFail');
        onFail();
        // Reset after fail
        setTimeout(() => {
          setSelected(new Set());
          setSubmitted(false);
        }, 2000);
      }
    }, 1500);
  };

  const getOptionState = (option: string) => {
    if (!submitted) return 'unselected';
    if (correctAnswers.includes(option) && selected.has(option)) return 'correct';
    if (correctAnswers.includes(option) && !selected.has(option)) return 'missed';
    if (!correctAnswers.includes(option) && selected.has(option)) return 'wrong';
    return 'neutral';
  };

  return (
    <LevelScene
      title="III. Meaning — Comprehension"
      instruction="Choose all definitions that capture the word's essence."
    >
      <div className="flex flex-col items-center mt-8 gap-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 w-full max-w-4xl">
          {shuffledOptions.map((option, idx) => {
            const state = getOptionState(option);
            const isSelected = selected.has(option);
            
            return (
              <motion.button
                key={idx}
                onClick={() => toggleSelection(option)}
                disabled={submitted}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.05 }}
                className={`
                  p-6 rounded text-left transition-all duration-300
                  ${!submitted && isSelected ? 'bg-white/20 border-2 border-white/40' : ''}
                  ${!submitted && !isSelected ? 'bg-gray-900/60 border-2 border-gray-700 hover:border-gray-600' : ''}
                  ${state === 'correct' ? 'bg-white/20 border-2 border-white/50 shadow-[0_0_20px_rgba(255,255,255,0.3)]' : ''}
                  ${state === 'wrong' ? 'bg-red-900/40 border-2 border-red-500/50' : ''}
                  ${state === 'missed' ? 'bg-gray-800/40 border-2 border-gray-600' : ''}
                  ${state === 'neutral' ? 'bg-gray-900/40 border-2 border-gray-800' : ''}
                  cursor-pointer disabled:cursor-not-allowed
                `}
              >
                <div className="flex items-start gap-4">
                  <div className={`
                    w-7 h-7 rounded border-2 flex-shrink-0 mt-1
                    flex items-center justify-center transition-all duration-300
                    ${isSelected ? 'bg-white/20 border-white/60' : 'border-gray-600'}
                  `}>
                    {isSelected && <span className="text-white text-sm">✓</span>}
                  </div>
                  <span className="text-gray-200 leading-relaxed text-lg">{option}</span>
                </div>
              </motion.button>
            );
          })}
        </div>

        {!submitted && (
          <motion.button
            onClick={handleSubmit}
            disabled={selected.size === 0}
            className="px-10 py-4 bg-white/10 text-white rounded border-2 border-white/30
                     hover:bg-white/20 hover:border-white/50 transition-all duration-300
                     disabled:opacity-50 disabled:cursor-not-allowed font-display uppercase tracking-wider text-lg font-bold"
          >
            Submit ({selected.size} selected)
          </motion.button>
        )}

        {submitted && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center space-y-4"
          >
            {[...selected].filter(s => correctAnswers.includes(s)).length >= minCorrectToPass &&
             [...selected].filter(s => !correctAnswers.includes(s)).length === 0 ? (
              <div className="text-white text-xl font-display">
                ✓ You have understood
              </div>
            ) : (
              <>
                <div className="text-red-400 text-xl font-display">
                  ✗ Some meanings slipped away
                </div>
                <motion.button
                  onClick={() => {
                    setSelected(new Set());
                    setSubmitted(false);
                  }}
                  className="px-8 py-3 bg-red-900/30 text-red-300 rounded border-2 border-red-500/50
                           hover:bg-red-900/50 hover:border-red-400/70 transition-all duration-300
                           font-display uppercase tracking-wider text-base font-bold"
                >
                  Try Again
                </motion.button>
              </>
            )}
          </motion.div>
        )}
      </div>
    </LevelScene>
  );
}

