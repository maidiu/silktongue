import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';
import StorySequence from './StorySequence';

// Cooldown Timer Component
function CooldownTimer({ cooldownUntil, onCooldownEnd }: { cooldownUntil: string; onCooldownEnd: () => void }) {
  const [timeLeft, setTimeLeft] = useState<string>('');

  useEffect(() => {
    const updateTimer = () => {
      const now = new Date().getTime();
      const cooldownTime = new Date(cooldownUntil).getTime();
      const difference = cooldownTime - now;

      if (difference > 0) {
        const hours = Math.floor(difference / (1000 * 60 * 60));
        const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((difference % (1000 * 60)) / 1000);
        setTimeLeft(`${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`);
      } else {
        setTimeLeft('00:00:00');
        onCooldownEnd();
      }
    };

    updateTimer();
    const interval = setInterval(updateTimer, 1000);
    return () => clearInterval(interval);
  }, [cooldownUntil, onCooldownEnd]);

  return (
    <div className="text-white font-mono text-2xl font-bold">
      {timeLeft}
    </div>
  );
}

interface BeastModeChallengeProps {
  wordId: number;
  onSuccess?: () => void;
  onFail?: () => void;
}

export default function BeastModeChallenge({ wordId, onSuccess, onFail }: BeastModeChallengeProps) {
  const [wagerAmount, setWagerAmount] = useState(10);
  const [maxWager, setMaxWager] = useState(0);
  const [silkBalance, setSilkBalance] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [cooldownUntil, setCooldownUntil] = useState<string>('');
  const [attemptId, setAttemptId] = useState<number | null>(null);
  const [isStarted, setIsStarted] = useState(false);
  const [level6Question, setLevel6Question] = useState<any>(null);

  useEffect(() => {
    checkBeastModeAvailability();
  }, [wordId]);

  const checkBeastModeAvailability = async () => {
    try {
      setIsLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/quiz/beast-mode/${wordId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();

      if (response.ok) {
        setMaxWager(data.maxWager || 100);
        setSilkBalance(data.silkBalance || 0);
        setWagerAmount(Math.min(data.maxWager || 100, 10));
        setCooldownUntil(data.cooldownUntil || null);
        setError('');
      } else {
        setError(data.error || 'Failed to check beast mode availability');
        setCooldownUntil(data.cooldownUntil || null);
      }
    } catch (err) {
      console.error('Failed to check beast mode availability:', err);
      setError('Failed to check beast mode availability');
    } finally {
      setIsLoading(false);
    }
  };

  const fetchLevel6Question = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/quiz/word/${wordId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        // Find Level 6 question - data is an array, not an object with questions property
        const level6 = data.find((q: any) => q.level === 6);
        setLevel6Question(level6);
      } else {
        console.error('Response not ok:', response.status, response.statusText);
      }
    } catch (err) {
      console.error('Failed to fetch Level 6 question:', err);
    }
  };

  const startBeastMode = async () => {
    try {
      setIsLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/quiz/beast-mode/${wordId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ wagerAmount })
      });

      const data = await response.json();

      if (response.ok) {
        setAttemptId(data.attemptId);
        setIsStarted(true);
        setSilkBalance(data.remainingSilk);
        // Fetch the Level 6 question when starting
        await fetchLevel6Question();
      } else {
        setError(data.error || 'Failed to start Beast mode');
      }
    } catch (err) {
      setError('Failed to start Beast mode');
    } finally {
      setIsLoading(false);
    }
  };

  const completeBeastMode = async (success: boolean) => {
    if (!attemptId) return;

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/quiz/beast-mode/${attemptId}/complete`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ success })
      });

      const data = await response.json();

      if (response.ok) {
        if (success && onSuccess) {
          onSuccess();
        } else if (!success && onFail) {
          onFail();
        }
      } else {
        setError(data.error || 'Failed to complete Beast mode');
      }
    } catch (err) {
      setError('Failed to complete Beast mode');
    }
  };

  if (isLoading) {
    return (
      <LevelScene title="VI. Beast Mode" instruction="Checking availability...">
        <div className="flex justify-center items-center h-64">
          <div className="text-gray-400">Loading...</div>
        </div>
      </LevelScene>
    );
  }

  if (error) {
    return (
      <LevelScene title="VI. Beast Mode" instruction="Beast mode unavailable">
        <div className="text-center py-16">
          <div className="text-red-400 text-6xl mb-6">⚔️</div>
          <h2 className="text-2xl font-display font-bold text-white mb-4">
            Beast Mode Locked
          </h2>
          <p className="text-gray-400 mb-8 max-w-md mx-auto">
            {error === 'Must complete normal quiz first' 
              ? 'Complete the normal quiz first to unlock Beast mode.'
              : error === 'Cooldown active'
              ? 'Beast mode is on cooldown. Wait 1 hour before attempting again.'
              : error
            }
          </p>
          {error === 'Cooldown active' && cooldownUntil && (
            <div className="bg-orange-900/20 p-4 rounded-lg border border-orange-500/30 max-w-md mx-auto mb-6">
              <div className="text-orange-400 font-display text-lg mb-2">Cooldown Timer</div>
              <CooldownTimer cooldownUntil={cooldownUntil} onCooldownEnd={() => window.location.reload()} />
            </div>
          )}
          <button
            onClick={() => window.location.reload()}
            className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30 hover:bg-white/20 hover:border-white/50 transition-all duration-300 font-display uppercase tracking-wider"
          >
            Refresh
          </button>
        </div>
      </LevelScene>
    );
  }

  if (!isStarted) {
    return (
      <LevelScene 
        title="VI. Beast Mode" 
        instruction="Wager your silk and face the ultimate challenge. Double or nothing."
      >
        <div className="flex flex-col items-center mt-8 gap-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-orange-400 font-display text-sm uppercase tracking-wider"
          >
            ⚠ Beast Mode — High Stakes Challenge
          </motion.div>

          <div className="bg-gray-800/50 p-6 rounded-lg border border-gray-700 max-w-md w-full">
            <div className="text-center mb-6">
              <div className="text-white font-display text-lg mb-2">Current Silk Balance</div>
              <div className="text-orange-400 font-display text-3xl">{silkBalance}</div>
            </div>

            <div className="mb-6">
              <label className="block text-gray-300 text-sm mb-2">Wager Amount</label>
              <div className="flex items-center gap-3">
                <input
                  type="range"
                  min="1"
                  max={maxWager}
                  value={wagerAmount}
                  onChange={(e) => setWagerAmount(parseInt(e.target.value))}
                  className="flex-1"
                />
                <div className="text-white font-display text-lg w-16 text-right">
                  {wagerAmount}
                </div>
              </div>
              <div className="text-gray-400 text-xs mt-1">
                Max wager: {maxWager} silk
              </div>
            </div>

            <div className="bg-orange-900/20 p-4 rounded border border-orange-500/30 mb-6">
              <div className="text-orange-300 font-display text-sm mb-2">Reward Calculation</div>
              <div className="text-white">
                Wager: {wagerAmount} silk
              </div>
              <div className="text-green-400">
                Win: +{wagerAmount * 2} silk (double your wager)
              </div>
              <div className="text-red-400">
                Lose: -{wagerAmount} silk (lose your wager)
              </div>
            </div>

            <button
              onClick={startBeastMode}
              disabled={isLoading || wagerAmount <= 0}
              className="w-full py-3 bg-orange-600 text-white rounded border-2 border-orange-500 hover:bg-orange-700 hover:border-orange-400 transition-all duration-300 font-display uppercase tracking-wider disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Starting...' : 'Enter Beast Mode'}
            </button>
          </div>
        </div>
      </LevelScene>
    );
  }

  // Beast mode challenge - render the actual Level 6 quiz
  if (!level6Question) {
    return (
      <LevelScene 
        title="VI. Beast Mode" 
        instruction="Loading challenge..."
      >
        <div className="flex justify-center items-center h-64">
          <div className="text-gray-400">Loading Level 6 challenge...</div>
        </div>
      </LevelScene>
    );
  }

  // Parse the Level 6 question data for StorySequence
  const options = level6Question.options || {};
  const redHerrings = level6Question.red_herrings || [];
  
  // Extract data from options object
  const timePeriods = options.time_periods || [];
  const settings = options.settings || [];
  const turns = options.turns || [];
  
  // Parse the correct answer if it's a JSON string
  let correctAnswer = level6Question.correct_answer;
  console.log('BEFORE PARSING - correctAnswer type:', typeof correctAnswer);
  console.log('BEFORE PARSING - correctAnswer value:', correctAnswer);
  
  if (typeof correctAnswer === 'string') {
    try {
      // The correct_answer is a JSON string that needs to be parsed
      const parsed = JSON.parse(correctAnswer);
      console.log('AFTER JSON.parse - parsed type:', typeof parsed);
      console.log('AFTER JSON.parse - parsed isArray:', Array.isArray(parsed));
      console.log('AFTER JSON.parse - parsed:', parsed);
      
      // If it's an object (PostgreSQL JSON array becomes object with numeric keys), convert to array
      if (typeof parsed === 'object' && !Array.isArray(parsed)) {
        correctAnswer = Object.values(parsed);
        console.log('CONVERTED to array:', correctAnswer);
      } else {
        correctAnswer = parsed;
        console.log('USED as-is:', correctAnswer);
      }
    } catch (e) {
      console.error('Failed to parse correct_answer:', e);
      console.log('Raw correct_answer:', level6Question.correct_answer);
      // If all parsing fails, just use an empty array
      correctAnswer = [];
    }
  }
  
  console.log('FINAL correctAnswer being passed to StorySequence:', correctAnswer);
  
  // The red herrings are story segments that need to be mixed with the correct turns
  // For Beast Mode, we need to include the red herrings in the turns array
  // so the user can identify and discard them
  const allTurns = [...turns, ...redHerrings];
  
  const redHerringData = {
    timePeriods: [], // No red herring time periods
    settings: [], // No red herring settings  
    turns: redHerrings // The red herrings are story segments
  };
  
  

  return (
    <StorySequence
      timePeriods={timePeriods}
      settings={settings}
      turns={allTurns}
      correctAnswer={correctAnswer}
      redHerrings={redHerringData}
      isHardMode={true}
      onSuccess={() => completeBeastMode(true)}
      onFail={() => completeBeastMode(false)}
    />
  );
}
