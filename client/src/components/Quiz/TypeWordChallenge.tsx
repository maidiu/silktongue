import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';

interface TypeWordChallengeProps {
  word: string;
  onSuccess?: () => void;
  onFail?: () => void;
}

export default function TypeWordChallenge({ word, onSuccess, onFail }: TypeWordChallengeProps) {
  const [input, setInput] = useState('');
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  // const [startTime] = useState(Date.now());

  useEffect(() => {
    // Auto-check when input length matches word length
    if (input.length === word.length) {
      checkAnswer();
    }
  }, [input]);

  const checkAnswer = () => {
    const isMatch = input.toLowerCase() === word.toLowerCase();
    setIsCorrect(isMatch);

    if (isMatch) {
      // const timeTaken = Math.floor((Date.now() - startTime) / 1000);
      setTimeout(() => {
        if (onSuccess) onSuccess();
      }, 1500);
    } else {
      if (onFail) onFail();
      // Reset after showing error
      setTimeout(() => {
        setInput('');
        setIsCorrect(null);
      }, 1500);
    }
  };

  return (
    <LevelScene
      title="II. Memory — Recall"
      instruction="Type the word from memory. Precision and rhythm."
    >
      <div className="flex flex-col items-center mt-8 gap-6">
        <div className="relative w-full max-w-md">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            disabled={isCorrect !== null}
            className={`
              w-full px-6 py-4 bg-gray-900/60 border-2 rounded
              text-2xl font-display text-center text-white
              focus:outline-none focus:ring-2 focus:ring-white/30
              transition-all duration-300
              ${isCorrect === true ? 'border-white/50 bg-white/10' : ''}
              ${isCorrect === false ? 'border-red-500/50 bg-red-900/20' : 'border-gray-700'}
            `}
            placeholder="Type the word..."
            autoFocus
          />
        </div>

        {isCorrect === true && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-white text-xl font-display"
          >
            ✓ You have remembered
          </motion.div>
        )}

        {isCorrect === false && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-red-400 text-xl font-display"
          >
            ✗ Not quite right
          </motion.div>
        )}

        <div className="text-gray-400 text-sm">
          {input.length} / {word.length} letters
        </div>
      </div>
    </LevelScene>
  );
}

