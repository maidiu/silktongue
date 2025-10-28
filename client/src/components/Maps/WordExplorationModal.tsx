import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../../contexts/AuthContext';

// TypeScript declarations for Web Speech API
declare global {
  interface Window {
    SpeechRecognition: any;
    webkitSpeechRecognition: any;
  }
}

interface WordExplorationModalProps {
  word: string;
  wordId: number;
  definitions: string[] | { primary: string; secondary?: string; tertiary?: string };
  synonyms: string[];
  antonyms: string[];
  etymology?: string;
  story?: any[]; // Story array from vocabulary entry
  story_intro?: string; // Story intro from vocabulary entry
  onClose: () => void;
  onComplete: () => void;
}

interface StoryQuestion {
  id: number;
  century: string;
  question: string;
  options: string[];
  correct_answer: string;
  explanation: string;
}

interface StoryProgress {
  story_completed: boolean;
  first_completion_at: string | null;
  last_studied_at: string | null;
  times_studied: number;
  total_silk_earned: number;
}

const WordExplorationModal: React.FC<WordExplorationModalProps> = ({
  word,
  wordId,
  definitions,
  synonyms,
  antonyms,
  etymology,
  story,
  story_intro,
  onClose,
  onComplete
}) => {
  const { user } = useAuth();
  const [step, setStep] = useState(1);
  
  // Debug: log props on mount
  useEffect(() => {
    console.log('🎯 WordExplorationModal props received:', { 
      word, 
      wordId, 
      storyLength: story?.length, 
      story, 
      story_intro,
      definitions 
    });
  }, [word, wordId, story, story_intro, definitions]);
  const [userDefinition, setUserDefinition] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const [pronunciationResult, setPronunciationResult] = useState<string | null>(null);
  const [pronunciationCorrect, setPronunciationCorrect] = useState<boolean | null>(null);
  
  // Story comprehension states
  const [storyQuestions, setStoryQuestions] = useState<StoryQuestion[]>([]);
  const [currentStoryIndex, setCurrentStoryIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string>('');
  const [showAnswerResult, setShowAnswerResult] = useState(false);
  const [answerResult, setAnswerResult] = useState<{isCorrect: boolean, explanation: string} | null>(null);
  const [storyProgress, setStoryProgress] = useState<StoryProgress | null>(null);
  const [isLoadingStory, setIsLoadingStory] = useState(false);
  const [showStoryText, setShowStoryText] = useState(true); // Show story text first, then question
  const [currentStoryStep, setCurrentStoryStep] = useState(0); // 0 = intro, 1+ = story entries

  // Helper function to format century numbers
  const formatCentury = (century: string) => {
    const num = parseInt(century);
    if (num === 1) return "1st century";
    if (num === 2) return "2nd century";
    if (num === 3) return "3rd century";
    return `${num}th century`;
  };

  // Fetch story questions and progress on component mount
  useEffect(() => {
    fetchStoryData();
  }, [wordId]);

  const fetchStoryData = async () => {
    try {
      console.log('Fetching story data for wordId:', wordId);
      const token = localStorage.getItem('token');
      console.log('Token exists:', !!token);
      
      const [questionsRes, progressRes] = await Promise.all([
        fetch(`/api/vocab/${wordId}/story-questions`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }),
        fetch(`/api/vocab/${wordId}/story-progress`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        })
      ]);

      console.log('Questions response status:', questionsRes.status);
      console.log('Progress response status:', progressRes.status);

      if (questionsRes.ok) {
        const questions = await questionsRes.json();
        console.log('Story questions loaded:', questions.length);
        setStoryQuestions(questions);
      } else {
        console.error('Failed to fetch questions:', questionsRes.status, await questionsRes.text());
      }

      if (progressRes.ok) {
        const progress = await progressRes.json();
        console.log('Story progress loaded:', progress);
        setStoryProgress(progress);
      } else {
        console.error('Failed to fetch progress:', progressRes.status, await progressRes.text());
      }
    } catch (error) {
      console.error('Error fetching story data:', error);
    }
  };

  const handlePronounce = async () => {
    setIsRecording(true);
    
    try {
      // Use Web Speech API for pronunciation
      if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        const recognition = new SpeechRecognition();
        
        recognition.lang = 'en-US';
        recognition.continuous = false;
        recognition.interimResults = false;
        
        recognition.onresult = (event: any) => {
          const transcript = event.results[0][0].transcript.toLowerCase().trim();
          setPronunciationResult(transcript);
          setPronunciationCorrect(transcript === word.toLowerCase());
        };
        
        recognition.onerror = (event: any) => {
          console.error('Speech recognition error:', event.error);
          setPronunciationResult('Error occurred');
          setPronunciationCorrect(false);
        };
        
        recognition.onend = () => {
          setIsRecording(false);
        };
        
        recognition.start();
      } else {
        setPronunciationResult('Speech recognition not supported');
        setPronunciationCorrect(false);
        setIsRecording(false);
      }
    } catch (error) {
      console.error('Error with speech recognition:', error);
      setPronunciationResult('Error occurred');
      setPronunciationCorrect(false);
      setIsRecording(false);
    }
  };

  const saveUserDefinition = async () => {
    try {
      const response = await fetch(`/api/vocab/${wordId}/definition`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ definition: userDefinition })
      });

      if (response.ok) {
        setStep(2);
      } else {
        console.error('Failed to save definition');
        setStep(2); // Continue anyway
      }
    } catch (error) {
      console.error('Error saving definition:', error);
      setStep(2); // Continue anyway
    }
  };

  const submitStoryAnswer = async () => {
    if (!selectedAnswer || !storyQuestions[currentStoryIndex]) return;

    try {
      const questionId = storyQuestions[currentStoryIndex].id;
      console.log('Submitting answer for questionId:', questionId, 'wordId:', wordId, 'answer:', selectedAnswer);
      
      const response = await fetch(`/api/vocab/${wordId}/story-answer`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          questionId: questionId,
          userAnswer: selectedAnswer
        })
      });

      console.log('Response status:', response.status);
      
      if (response.ok) {
        const result = await response.json();
        setAnswerResult({
          isCorrect: result.isCorrect,
          explanation: result.explanation
        });
        setShowAnswerResult(true);
      } else {
        const errorText = await response.text();
        console.error('Error submitting answer:', response.status, errorText);
        alert('Failed to submit answer. Please try again.');
      }
    } catch (error) {
      console.error('Error submitting answer:', error);
      alert('Failed to submit answer. Please try again.');
    }
  };

  const nextStoryQuestion = () => {
    if (currentStoryIndex < storyQuestions.length - 1) {
      setCurrentStoryIndex(currentStoryIndex + 1);
      setSelectedAnswer('');
      setShowAnswerResult(false);
      setAnswerResult(null);
      setShowStoryText(true); // Show story text first for next question
    } else {
      // Story completed
      completeStoryStudy();
    }
  };

  const completeStoryStudy = async () => {
    setIsLoadingStory(true);
    try {
      const response = await fetch(`/api/vocab/${wordId}/complete-story`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const result = await response.json();
        alert(result.message);
        setStep(6); // Move to completion step
      }
    } catch (error) {
      console.error('Error completing story:', error);
    } finally {
      setIsLoadingStory(false);
    }
  };

  const startBattle = () => {
    const confirmed = window.confirm(
      `⚠️ BATTLE WARNING ⚠️\n\n` +
      `You are about to enter a 5-round battle for "${word}".\n\n` +
      `• You will lose health for each mistake\n` +
      `• You must complete all 5 rounds without losing all health\n` +
      `• Higher difficulty words (C2) award more silk\n` +
      `• Current word difficulty: ${storyProgress?.times_studied === 0 ? 'C1' : 'C2'}\n\n` +
      `Are you sure you want to proceed?`
    );
    
    if (confirmed) {
      onComplete(); // This will navigate to the quiz
    }
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              What do you think "{word}" means?
            </h3>
            
            <p className="text-gray-300 mb-4">
              Before we reveal the true meaning, write down what you think this word means (if anything).
              This is your initial understanding—we'll see how close you are!
            </p>
            
            <textarea
              value={userDefinition}
              onChange={(e) => setUserDefinition(e.target.value)}
              placeholder="Write your definition here..."
              className="w-full p-4 bg-gray-800 text-white rounded-lg border-2 border-gray-600 focus:border-blue-500 focus:outline-none min-h-[120px]"
              rows={4}
            />
            
            <div className="flex gap-4">
              <button
                onClick={saveUserDefinition}
                disabled={!userDefinition.trim()}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Continue
              </button>
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
            </div>
          </motion.div>
        );
        
      case 2:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              Pronounce "{word}"
            </h3>
            
            <p className="text-gray-300 mb-4">
              Now, let's learn how to say this word. Click the button below and say "{word}" aloud.
              We'll check if your pronunciation matches!
            </p>
            
            <button
              onClick={handlePronounce}
              disabled={isRecording}
              className="w-full px-6 py-4 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-lg font-bold"
            >
              {isRecording ? '🎤 Listening...' : '🎤 Pronounce Word'}
            </button>
            
            {pronunciationResult && (
              <div className={`p-4 border-2 rounded-lg ${
                pronunciationCorrect 
                  ? 'bg-green-900/30 border-green-500' 
                  : 'bg-red-900/30 border-red-500'
              }`}>
                <p className={`text-center font-bold ${
                  pronunciationCorrect ? 'text-green-200' : 'text-red-200'
                }`}>
                  {pronunciationCorrect ? '✓ Correct!' : '✗ Incorrect'}
                </p>
                <p className="text-gray-300 text-center mt-2">
                  You said: "{pronunciationResult}"
                </p>
                {!pronunciationCorrect && (
                  <p className="text-gray-400 text-center mt-2">
                    Expected: "{word}"
                  </p>
                )}
              </div>
            )}
            
            <div className="flex gap-4">
              <button
                onClick={() => setStep(3)}
                disabled={!pronunciationResult}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Continue
              </button>
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
            </div>
          </motion.div>
        );
        
      case 3:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              The True Meaning
            </h3>
            
            <div className="p-4 bg-blue-900/30 border-2 border-blue-500 rounded-lg">
              <h4 className="text-blue-200 font-bold mb-2">The True Definition:</h4>
              <p className="text-white">{
                typeof definitions === 'object' && !Array.isArray(definitions) && 'primary' in definitions && definitions.primary
                  ? definitions.primary
                  : Array.isArray(definitions) && definitions.length > 0 
                    ? definitions[0] 
                    : typeof definitions === 'string' 
                      ? definitions 
                      : 'No definition available'
              }</p>
            </div>
            
            <div className="p-4 bg-purple-900/30 border-2 border-purple-500 rounded-lg">
              <h4 className="text-purple-200 font-bold mb-2">Your Definition:</h4>
              <p className="text-white">{userDefinition || 'No definition entered'}</p>
            </div>
            
            <div className="p-4 bg-amber-900/30 border-2 border-amber-500 rounded-lg">
              <h4 className="text-amber-200 font-bold mb-2">Was your definition close?</h4>
              <p className="text-white">
                Compare your initial understanding with the true meaning. Don't worry if you were off—
                that's how learning works!
              </p>
            </div>
            
            <div className="flex gap-4">
              <button
                onClick={() => setStep(4)}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Continue
              </button>
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
            </div>
          </motion.div>
        );
        
      case 4:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              {word}'s Brothers and Shadow Selves
            </h3>
            
            <p className="text-gray-300 mb-4">
              Here are {word}'s synonyms (brothers) and antonyms (shadow selves).
              Some you will know, some you will have to remember. Study them until you are confident.
            </p>
            
            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 bg-green-900/30 border-2 border-green-500 rounded-lg">
                <h4 className="text-green-200 font-bold mb-2">Brothers (Synonyms):</h4>
                <ul className="text-white space-y-1">
                  {synonyms.map((syn, idx) => (
                    <li key={idx}>• {syn}</li>
                  ))}
                </ul>
              </div>
              
              <div className="p-4 bg-red-900/30 border-2 border-red-500 rounded-lg">
                <h4 className="text-red-200 font-bold mb-2">Shadow Selves (Antonyms):</h4>
                <ul className="text-white space-y-1">
                  {antonyms.map((ant, idx) => (
                    <li key={idx}>• {ant}</li>
                  ))}
                </ul>
              </div>
            </div>
            
            <div className="flex gap-4">
              <button
                onClick={() => setStep(5)}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Continue
              </button>
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
            </div>
          </motion.div>
        );
        
      case 5:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              The Life Story of {word}
            </h3>
            
            <p className="text-gray-300 mb-6">
              You must know {word} not as it is now, but who it once was, who it has been,
              and how it has become what it is today. It is only once you truly *know* its life
              that you will know its power, be worthy to carry it with you on your journey.
            </p>
            
            {showStoryText ? (
              // Show story content (intro or story entry)
              <div className="space-y-4">
                {currentStoryStep === 0 ? (
                  // Show story intro
                  <div className="p-4 bg-purple-900/30 border-2 border-purple-500 rounded-lg">
                    <h4 className="text-purple-200 font-bold mb-2">Introduction</h4>
                    <p className="text-white mb-4">
                      {story_intro || `This is the story of ${word} and how it has evolved through time.`}
                    </p>
                    
                    <div className="flex gap-4">
                      <button
                        onClick={() => {
                          setCurrentStoryStep(1);
                          setCurrentStoryIndex(0); // Reset to first question
                        }}
                        className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                      >
                        Begin the Story
                      </button>
                    </div>
                  </div>
                ) : (
                  // Show story entry
                  <div className="p-4 bg-purple-900/30 border-2 border-purple-500 rounded-lg">
                    <h4 className="text-purple-200 font-bold mb-2">
                      {story && story[currentStoryStep - 1] ? formatCentury(story[currentStoryStep - 1].century) : 'Story'}
                    </h4>
                    <p className="text-white mb-4">
                      {story && story[currentStoryStep - 1] ? (story[currentStoryStep - 1].story_text || story[currentStoryStep - 1].event_text) : 'Story content not available.'}
                    </p>
                    
                    {story && story[currentStoryStep - 1] && (
                      <div className="mb-4 space-y-2">
                        <div className="text-blue-200 text-sm">
                          <strong>Context:</strong> {story[currentStoryStep - 1].context}
                        </div>
                        {story[currentStoryStep - 1].sibling_words && story[currentStoryStep - 1].sibling_words.length > 0 && (
                          <div className="text-green-200 text-sm">
                            <strong>Sibling Words:</strong> {story[currentStoryStep - 1].sibling_words.join(', ')}
                          </div>
                        )}
                      </div>
                    )}
                    
                    <div className="flex gap-4">
                      <button
                        onClick={() => setShowStoryText(false)}
                        className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                      >
                        Continue to Question
                      </button>
                    </div>
                  </div>
                )}
                
                <div className="text-center text-gray-400">
                  {currentStoryStep === 0 ? 'Introduction' : 
                   story ? `Story ${currentStoryStep} of ${story.length}` : 'Story'}
                </div>
              </div>
            ) : (
              // Show question
              <div className="space-y-4">
                <div className="p-4 bg-purple-900/30 border-2 border-purple-500 rounded-lg">
                  <h4 className="text-purple-200 font-bold mb-2">
                    {story && story[currentStoryStep - 1] ? formatCentury(story[currentStoryStep - 1].century) : 'Question'} - Question
                  </h4>
                  <p className="text-white mb-4">
                    {storyQuestions.length > 0 && storyQuestions[currentStoryIndex] ? 
                     storyQuestions[currentStoryIndex].question : 
                     'Question not available.'}
                  </p>
                  
                  <div className="space-y-2">
                    {storyQuestions.length > 0 && storyQuestions[currentStoryIndex] ? 
                     storyQuestions[currentStoryIndex].options.map((option, idx) => (
                      <button
                        key={idx}
                        onClick={() => setSelectedAnswer(option)}
                        className={`w-full p-3 text-left rounded-lg border-2 transition-colors ${
                          selectedAnswer === option
                            ? 'bg-blue-600 border-blue-400 text-white'
                            : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                        }`}
                      >
                        {String.fromCharCode(65 + idx)}) {option}
                      </button>
                    )) : (
                      <p className="text-gray-400">No question available</p>
                    )}
                  </div>
                  
                  {showAnswerResult && answerResult && (
                    <div className={`mt-4 p-4 border-2 rounded-lg ${
                      answerResult.isCorrect 
                        ? 'bg-green-900/30 border-green-500' 
                        : 'bg-red-900/30 border-red-500'
                    }`}>
                      <p className={`font-bold ${
                        answerResult.isCorrect ? 'text-green-200' : 'text-red-200'
                      }`}>
                        {answerResult.isCorrect ? '✓ Correct!' : '✗ Incorrect'}
                      </p>
                      <p className="text-gray-300 mt-2">{answerResult.explanation}</p>
                    </div>
                  )}
                  
                  <div className="flex gap-4 mt-4">
                    {!showAnswerResult ? (
                      <button
                        onClick={submitStoryAnswer}
                        disabled={!selectedAnswer}
                        className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Submit Answer
                      </button>
                    ) : (
                      <button
                        onClick={() => {
                          if (story && currentStoryStep < story.length) {
                            // Move to next story section
                            setCurrentStoryStep(currentStoryStep + 1);
                            setCurrentStoryIndex(currentStoryIndex + 1);
                            setShowStoryText(true);
                            setSelectedAnswer('');
                            setShowAnswerResult(false);
                            setAnswerResult(null);
                          } else {
                            // All story sections completed
                            completeStoryStudy();
                          }
                        }}
                        className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                      >
                        {story && currentStoryStep < story.length ? 'Next Story Section' : 'Complete Story'}
                      </button>
                    )}
                  </div>
                </div>
                
                <div className="text-center text-gray-400">
                  Question {currentStoryIndex + 1} of {storyQuestions.length}
                </div>
              </div>
            )}
            
            <div className="flex gap-4">
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
            </div>
          </motion.div>
        );

      case 6:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <h3 className="text-2xl font-bold text-white mb-4">
              🎉 Story Study Complete!
            </h3>
            
            <div className="p-4 bg-green-900/30 border-2 border-green-500 rounded-lg">
              <h4 className="text-green-200 font-bold mb-2">Congratulations!</h4>
              <p className="text-white">
                You have completed the story study for "{word}". You now understand its journey through time
                and are ready to prove your mastery in battle.
              </p>
            </div>

            {storyProgress && (
              <div className="p-4 bg-blue-900/30 border-2 border-blue-500 rounded-lg">
                <h4 className="text-blue-200 font-bold mb-2">Study Progress:</h4>
                <p className="text-white">
                  Times studied: {storyProgress.times_studied}<br/>
                  Total silk earned: {storyProgress.total_silk_earned}
                </p>
              </div>
            )}
            
            <div className="space-y-4">
              <button
                onClick={startBattle}
                className="w-full px-6 py-4 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-lg font-bold"
              >
                ⚔️ Battle for "{word}"
              </button>
              
              <button
                onClick={() => {
                  setStep(5);
                  setCurrentStoryIndex(0);
                  setSelectedAnswer('');
                  setShowAnswerResult(false);
                  setAnswerResult(null);
                }}
                className="w-full px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
              >
                📚 Study Story Again
              </button>
            </div>
            
            <div className="flex gap-4">
              <button
                onClick={onClose}
                className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Return to Map
              </button>
            </div>
          </motion.div>
        );
        
      default:
        return null;
    }
  };

  return (
    <div className="w-full max-w-4xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-gradient-to-br from-gray-900 to-gray-800 border-2 border-blue-500 rounded-xl p-8 max-h-[90vh] overflow-y-auto shadow-2xl"
      >
        <AnimatePresence mode="wait">
          {renderStep()}
        </AnimatePresence>
      </motion.div>
    </div>
  );
};

export default WordExplorationModal;