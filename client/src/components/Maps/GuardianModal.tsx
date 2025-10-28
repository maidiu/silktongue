import { useState } from 'react';
import { motion } from 'framer-motion';

interface DialogueEntry {
  order: number;
  word: string;
  paragraph: string;
}

interface GuardianData {
  floor: number;
  guardian: string;
  intro: string;
  dialogue: DialogueEntry[];
  completion: string;
}

interface GuardianModalProps {
  guardianData: GuardianData;
  onClose: () => void;
  onComplete: () => void;
}

export default function GuardianModal({ guardianData, onClose, onComplete }: GuardianModalProps) {
  console.log('🎭 GuardianModal rendering with data:', guardianData);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [currentAnswer, setCurrentAnswer] = useState('');
  const [showCompletion, setShowCompletion] = useState(false);

  const handleSubmit = () => {
    const currentDialogue = guardianData.dialogue[currentIndex];
    const isCorrect = currentAnswer.toLowerCase().trim() === currentDialogue.word.toLowerCase();
    
    if (isCorrect) {
      if (currentIndex === guardianData.dialogue.length - 1) {
        // Last word correct, show completion
        setShowCompletion(true);
      } else {
        // Move to next dialogue
        setCurrentIndex(currentIndex + 1);
        setCurrentAnswer('');
      }
    } else {
      alert(`Incorrect. Try again.`);
    }
  };

  const handleFinalComplete = async () => {
    // Call API to unlock next floor
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/maps/unlock-next-floor`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ currentFloor: guardianData.floor })
      });

      const data = await response.json();
      if (data.success) {
        alert(data.message);
        onComplete();
      } else {
        alert(data.error || 'Failed to unlock next floor');
      }
    } catch (error) {
      alert('Failed to unlock next floor');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/90 z-[300] flex items-center justify-center p-8">
      <div 
        className="bg-gray-800 w-full max-w-4xl max-h-[90vh] rounded-xl border border-gray-700 overflow-hidden shadow-2xl flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b border-gray-700">
          <h2 className="text-3xl font-display font-bold text-white">
            👹 {guardianData.guardian}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white text-3xl p-2 hover:bg-gray-700 rounded-lg transition-colors"
          >
            ×
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {showCompletion ? (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-6"
            >
              <div className="text-white text-lg leading-relaxed italic">
                {guardianData.completion}
              </div>
              <button
                onClick={handleFinalComplete}
                className="w-full px-8 py-4 bg-green-600 hover:bg-green-700 text-white font-bold text-xl rounded-lg transition-colors"
              >
                Ascend to Next Floor
              </button>
            </motion.div>
          ) : (
            <motion.div 
              className="space-y-6"
              key={currentIndex}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              {/* Show intro only for first dialogue */}
              {currentIndex === 0 && (
                <div className="text-gray-300 leading-relaxed">
                  {guardianData.intro}
                </div>
              )}

              {/* Current dialogue block */}
              <div className="bg-gray-900/50 p-6 rounded-lg border border-gray-700">
                <div className="text-white text-lg italic mb-6 leading-relaxed">
                  {guardianData.dialogue[currentIndex].paragraph}
                </div>
                
                <div className="bg-gray-800 p-4 rounded-lg border border-gray-600">
                  <label className="block text-gray-400 text-sm mb-2">
                    What word is the {guardianData.guardian.toLowerCase()} searching for?
                  </label>
                  <input
                    type="text"
                    value={currentAnswer}
                    onChange={(e) => setCurrentAnswer(e.target.value)}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleSubmit();
                      }
                    }}
                    placeholder="Speak the word..."
                    className="w-full bg-gray-700 text-white px-4 py-3 rounded border border-gray-600 focus:border-blue-500 focus:outline-none text-lg"
                    autoFocus
                  />
                </div>
              </div>

              {/* Progress indicator */}
              <div className="text-center text-gray-400 text-sm">
                Word {currentIndex + 1} of {guardianData.dialogue.length}
              </div>

              {/* Submit button */}
              <button
                onClick={handleSubmit}
                disabled={!currentAnswer.trim()}
                className="w-full px-8 py-4 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 disabled:cursor-not-allowed text-white font-bold text-lg rounded-lg transition-colors"
              >
                Speak the Word
              </button>
            </motion.div>
          )}
        </div>
      </div>
    </div>
  );
}

