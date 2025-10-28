import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { useQuizProgress } from '../hooks/useQuizProgress';
import SpellingPuzzle from '../components/Quiz/SpellingPuzzle';
import TypeWordChallenge from '../components/Quiz/TypeWordChallenge';
import MeaningMatch from '../components/Quiz/MeaningMatch';
import SynAntDuel from '../components/Quiz/SynAntDuel';
import StorySequence from '../components/Quiz/StorySequence';
import BeastModeChallenge from '../components/Quiz/BeastModeChallenge';
import Loader from '../components/Shared/Loader';

interface QuizQuestion {
  id: number;
  word_id: number;
  level: number;
  question_type: string;
  prompt: string;
  options: any;
  correct_answer: string | null;
  correct_answers?: string[] | null;
  incorrect_answers?: string[] | null;
  variant_data: any;
  reward_amount: number;
  difficulty: string;
}

export default function QuizPage() {
  const { wordId } = useParams<{ wordId: string }>();
  const navigate = useNavigate();
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [word, setWord] = useState('');
  const [isLoadingQuestions, setIsLoadingQuestions] = useState(true);
  const [localLevel, setLocalLevel] = useState(1);
  const [isReviewMode, setIsReviewMode] = useState(false);
  
  // Validate wordId exists and is a valid number
  const validWordId = parseInt(wordId || '0', 10);
  if (!wordId || wordId === 'null' || wordId === 'undefined' || isNaN(validWordId) || validWordId === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-400 text-xl">Invalid word ID: {wordId}</div>
      </div>
    );
  }
  
  const { level, health, silk, isComplete, isLoading, stats, advance, recordFailure } = useQuizProgress(validWordId);

  // Load questions and word data
  useEffect(() => {
    const loadData = async () => {
      try {
        // Load quiz questions
        const quizRes = await fetch(`/api/quiz/word/${validWordId}`);
        const quizData = await quizRes.json();
        setQuestions(quizData);

        // Load word info
        const wordRes = await fetch(`/api/vocab/${validWordId}`);
        const wordData = await wordRes.json();
        setWord(wordData.word);

        setIsLoadingQuestions(false);
      } catch (err) {
        console.error('Failed to load quiz data:', err);
        setIsLoadingQuestions(false);
      }
    };

    if (validWordId > 0) {
      loadData();
    }
  }, [validWordId]);

  const currentQuestion = questions.find(q => q.level === level);

  const handleSuccess = async () => {
    if (isReviewMode) {
      // In review mode, just advance locally without backend calls
      setLocalLevel(prev => Math.min(prev + 1, 6));
    } else {
      await advance();
    }
  };

  const handleFail = async () => {
    if (!isReviewMode) {
      const healthLost = currentQuestion?.variant_data?.hard_mode_penalty?.health_loss_on_fail || 1;
      await recordFailure(healthLost);
    }
    // In review mode, no health penalty - just let them try again (do nothing)
  };

  // Sync local level with actual level (but not in review mode)
  useEffect(() => {
    if (!isReviewMode) {
      setLocalLevel(level);
    }
  }, [level, isReviewMode]);

  // Handle loading and error states
  if (isLoading || isLoadingQuestions) {
    return <Loader />;
  }

  if (validWordId <= 0) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-display text-white mb-4">Invalid Word ID</h2>
          <button
            onClick={() => navigate('/')}
            className="px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
          >
            Go Home
          </button>
        </div>
      </div>
    );
  }

  if (!currentQuestion) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-400">No question found for this level.</p>
      </div>
    );
  }

  if (health <= 0) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center p-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center space-y-6"
        >
          <h1 className="text-4xl font-display font-bold text-red-400">
            Health Depleted
          </h1>
          <p className="text-xl text-gray-300">
            Return tomorrow to continue your journey.
          </p>
          <div className="text-6xl">💔</div>
          <motion.button
            onClick={() => navigate('/')}
            className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30
                     hover:bg-white/20 hover:border-white/50 transition-all duration-300
                     font-display uppercase tracking-wider"
          >
            Return Home
          </motion.button>
        </motion.div>
      </div>
    );
  }

  const renderLevel = () => {
    // If in review mode and completed all levels, show review completion
    if (isReviewMode && localLevel > 5) {
      return (
        <div className="text-center py-16">
          <div className="text-blue-400 text-6xl mb-6">✓</div>
          <h2 className="text-3xl font-display font-bold text-white mb-4">
            Review Complete!
          </h2>
          <p className="text-gray-400 mb-8 max-w-md mx-auto">
            You've reviewed all levels for this word.
          </p>
          
          <div className="flex flex-col gap-4 max-w-md mx-auto">
            <button
              onClick={() => {
                // Exit review mode and return to normal state
                setIsReviewMode(false);
                setLocalLevel(level);
              }}
              className="px-8 py-3 bg-blue-600 text-white rounded border-2 border-blue-500 hover:bg-blue-700 hover:border-blue-400 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Exit Review Mode
            </button>
            
            <button
              onClick={() => {
                // Review again from the beginning
                setLocalLevel(1);
              }}
              className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30 hover:bg-white/20 hover:border-white/50 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Review Again
            </button>
            
            <button
              onClick={() => {
                navigate('/maps');
              }}
              className="px-8 py-3 bg-purple-600 text-white rounded border-2 border-purple-500 hover:bg-purple-700 hover:border-purple-400 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Back to Maps
            </button>
          </div>
        </div>
      );
    }
    
    // If quiz is complete, show Beast mode option
    if (isComplete && localLevel > 5) {
      return (
        <BeastModeChallenge
          wordId={parseInt(wordId || '0')}
          onSuccess={() => {
            // Refresh user data and show success
            window.location.reload();
          }}
          onFail={() => {
            // Refresh user data and show failure
            window.location.reload();
          }}
        />
      );
    }


    // If quiz is complete, show completion screen
    if (isComplete) {
      return (
        <div className="text-center py-16">
          <div className="text-green-400 text-6xl mb-6">✓</div>
          <h2 className="text-3xl font-display font-bold text-white mb-4">
            Congratulations!
          </h2>
          <p className="text-gray-400 mb-8 max-w-md mx-auto">
            You've mastered this word! Your knowledge has been rewarded.
          </p>
          <div className="bg-gray-800/50 p-6 rounded-lg border border-gray-700 max-w-md mx-auto mb-8">
            <div className="text-sm text-gray-400 mb-2">Silk Earned:</div>
            <div className="text-orange-400 font-display text-2xl">{silk} silk</div>
          </div>
          
          <div className="flex flex-col gap-4 max-w-md mx-auto">
            <button
              onClick={() => {
                // Trigger Beast mode by setting level to 6
                setLocalLevel(6);
              }}
              className="px-8 py-3 bg-orange-600 text-white rounded border-2 border-orange-500 hover:bg-orange-700 hover:border-orange-400 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Enter Beast Mode
            </button>
            
            <button
              onClick={() => {
                // Review quiz - restart from level 1 in review mode (no health/silk changes)
                setIsReviewMode(true);
                setLocalLevel(1);
              }}
              className="px-8 py-3 bg-blue-600 text-white rounded border-2 border-blue-500 hover:bg-blue-700 hover:border-blue-400 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Review Quiz
            </button>
            
            <button
              onClick={() => {
                // Return to main page
                navigate('/');
              }}
              className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30 hover:bg-white/20 hover:border-white/50 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Return to Main Page
            </button>
            
            <button
              onClick={() => {
                // Return to maps
                navigate('/maps');
              }}
              className="px-8 py-3 bg-purple-600 text-white rounded border-2 border-purple-500 hover:bg-purple-700 hover:border-purple-400 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Back to Maps
            </button>
          </div>
        </div>
      );
    }

    // Get all questions for this level
    const levelQuestions = questions.filter(q => q.level === localLevel);
    
    // If no question found, show error
    if (levelQuestions.length === 0) {
      return <p className="text-gray-400">No question found for level {localLevel}</p>;
    }
    
    // If multiple questions at this level, pick one at random for variety
    const currentQuestion = levelQuestions.length > 1 
      ? levelQuestions[Math.floor(Math.random() * levelQuestions.length)]
      : levelQuestions[0];

    // If we have a question, render it
    if (currentQuestion) {
      switch (currentQuestion.question_type) {
      case 'spelling':
        return <SpellingPuzzle word={word} onSuccess={handleSuccess} />;
      
      case 'typing':
        return <TypeWordChallenge word={word} onSuccess={handleSuccess} onFail={handleFail} />;
      
      case 'definition':
        // For definition questions, we need to generate options from incorrect_answers and correct_answers
        // Check if they're at the top level (new structure) or in options (old structure)
        let incorrectAnswers: string[] = [];
        let correctAnswersPool: string[] = [];
        
        if (currentQuestion.incorrect_answers && currentQuestion.correct_answers) {
          // New structure: top-level incorrect_answers and correct_answers
          incorrectAnswers = currentQuestion.incorrect_answers;
          correctAnswersPool = currentQuestion.correct_answers;
        } else if (currentQuestion.options && typeof currentQuestion.options === 'object') {
          // Old structure: nested in options
          incorrectAnswers = currentQuestion.options.incorrect_answers || [];
          correctAnswersPool = currentQuestion.options.correct_answers || [];
        }
        
        // Select 3 random incorrect answers
        const shuffledIncorrect = [...incorrectAnswers].sort(() => Math.random() - 0.5);
        const selectedIncorrect = shuffledIncorrect.slice(0, 3);
        
        // Select 1 random correct answer
        const shuffledCorrect = [...correctAnswersPool].sort(() => Math.random() - 0.5);
        const selectedCorrect = shuffledCorrect.slice(0, 1);
        
        const displayOptions = [...selectedIncorrect, ...selectedCorrect];
        const correctAnswers = selectedCorrect;
        
        return (
          <MeaningMatch
            options={displayOptions}
            correctAnswers={correctAnswers}
            minCorrectToPass={1}
            onSuccess={handleSuccess}
            onFail={handleFail}
          />
        );
      
      case 'synonym':
      case 'syn_ant_sort':
        // Parse options if it's a string
        let synAntOptions = currentQuestion.options;
        if (typeof synAntOptions === 'string') {
          try {
            synAntOptions = JSON.parse(synAntOptions);
          } catch (e) {
            console.error('Failed to parse syn_ant_sort options:', e);
            synAntOptions = {};
          }
        }
        
        // Only use synonyms and antonyms, ignore red herrings
        return (
          <SynAntDuel
            synonyms={synAntOptions?.synonyms || []}
            antonyms={synAntOptions?.antonyms || []}
            redHerrings={[]}
            minCorrectToPass={currentQuestion.variant_data?.min_correct_to_pass || 6}
            onSuccess={handleSuccess}
            onFail={handleFail}
          />
        );
      
      case 'story':
      case 'story_reorder':
        // Story questions are three-column sequencing
        const storyOptions = currentQuestion.options;
        const timePeriods = storyOptions?.time_periods || [];
        // Handle both old format (settings + turns) and new simplified format (story_texts only)
        const settings = storyOptions?.settings || [];
        const turns = storyOptions?.turns || storyOptions?.story_texts || [];
        const redHerrings = storyOptions?.red_herrings || [];
        
        // Parse correct_answer - it might be a string or already parsed
        let correctAnswer: string[] = [];
        if (typeof currentQuestion.correct_answer === 'string') {
          try {
            correctAnswer = JSON.parse(currentQuestion.correct_answer);
          } catch {
            correctAnswer = [];
          }
        } else if (Array.isArray(currentQuestion.correct_answer)) {
          correctAnswer = currentQuestion.correct_answer;
        }
        
        // Parse red herrings into separate arrays
        const redHerringData = {
          timePeriods: redHerrings.filter((h: string) => h.includes('c.') || h.includes('century')),
          settings: redHerrings.filter((h: string) => !h.includes('c.') && !h.includes('century') && !h.includes('→')),
          turns: redHerrings.filter((h: string) => h.includes('→'))
        };
        
        return (
          <StorySequence
            timePeriods={timePeriods}
            settings={settings}
            turns={turns}
            correctAnswer={correctAnswer}
            redHerrings={redHerringData}
            isHardMode={currentQuestion.difficulty === 'hard' || currentQuestion.variant_data?.difficulty === 'hard'}
            onSuccess={handleSuccess}
            onFail={handleFail}
          />
        );
      
      default:
        return <p className="text-gray-400">Unknown question type</p>;
      }
    }

    // If we get here, something went wrong
    return <p className="text-gray-400">No question available</p>;
  };

  return (
    <div className="min-h-screen flex flex-col relative overflow-hidden" style={{ alignItems: 'space-between', justifyContent: 'space-between' }}>
      {/* Stats HUD */}
      <div className="absolute top-4 right-4 z-10 text-white font-display">
        <br></br><br></br>
        {isReviewMode && (
          <div className="mb-4 px-3 py-2 bg-blue-600/30 border border-blue-500 rounded">
            <div className="text-sm text-blue-200">📖 Review Mode</div>
            <div className="text-xs text-blue-300">No health or silk changes</div>
          </div>
        )}
        <div className="mb-4">
          <div className="text-sm text-gray-400 mb-1">Health:</div>
          <div className="text-lg tracking-wider text-red-500">{'❤️'.repeat(health).split('').join(' ')}</div>
        </div>
        <div><br></br>
          <div className="text-sm text-gray-400 mb-1">Silk:</div>
          <div className="text-lg text-orange-400">{stats?.silkBalance || 0}</div>
        </div>
      </div>

      {/* Level indicator */}
      <div className="absolute top-4 left-4 z-10">
        <div className="text-sm text-gray-400 font-display">
          Level {localLevel} of {questions.length}
        </div>
      </div>

      {/* Main content */}
      <div className="flex-1 flex items-center justify-center p-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={localLevel}
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -40 }}
            transition={{ duration: 0.6 }}
            className="w-full"
          >
            {renderLevel()}
          </motion.div>
        </AnimatePresence>
      </div>
    </div>
  );
}

