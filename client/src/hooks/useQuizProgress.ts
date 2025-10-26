import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';

// interface QuizProgress {
//   currentLevel: number;
//   maxLevelReached: number;
//   healthRemaining: number;
//   silkEarned: number;
//   completedAt: string | null;
// }

interface QuizStats {
  silkBalance: number;
  wordsMastered: number;
  quizzesCompleted: number;
  totalHealthLost: number;
}

export function useQuizProgress(wordId: number) {
  const { refreshUser } = useAuth();
  const [level, setLevel] = useState(1);
  const [health, setHealth] = useState(5);
  const [silk, setSilk] = useState(0);
  const [isComplete, setIsComplete] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [stats, setStats] = useState<QuizStats | null>(null);

  // Helper function to get auth headers
  const getAuthHeaders = () => {
    const token = localStorage.getItem('token');
    return {
      'Content-Type': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` })
    };
  };

  // Load progress on mount
  useEffect(() => {
    const loadProgress = async () => {
      try {
        // Start or get existing quiz
        const startRes = await fetch(`/api/quiz/start/${wordId}`, {
          method: 'POST',
          headers: getAuthHeaders()
        });
        const startData = await startRes.json();

        setLevel(startData.current_level);
        setHealth(startData.health_remaining);
        setSilk(startData.silk_earned);
        setIsComplete(!!startData.completed_at);

        // Load user stats
        const statsRes = await fetch('/api/quiz/stats', {
          headers: getAuthHeaders()
        });
        const statsData = await statsRes.json();
        setStats({
          silkBalance: statsData.silk_balance,
          wordsMastered: statsData.words_mastered,
          quizzesCompleted: statsData.quizzes_completed,
          totalHealthLost: statsData.total_health_lost
        });

        setIsLoading(false);
      } catch (err) {
        console.error('Failed to load quiz progress:', err);
        setIsLoading(false);
      }
    };

    loadProgress();
  }, [wordId]);

  // Advance to next level (called on success)
  const advance = async (timeTaken?: number) => {
    try {
      const res = await fetch('/api/quiz/level-complete', {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ wordId, level, timeTaken })
      });
      const data = await res.json();

      setLevel(data.nextLevel || data.current_level);
      setSilk(data.silk_earned);
      setIsComplete(data.isComplete);

      // Refresh stats
      const statsRes = await fetch('/api/quiz/stats', {
        headers: getAuthHeaders()
      });
      const statsData = await statsRes.json();
      setStats({
        silkBalance: statsData.silk_balance,
        wordsMastered: statsData.words_mastered,
        quizzesCompleted: statsData.quizzes_completed,
        totalHealthLost: statsData.total_health_lost
      });

      // Refresh user context to update header
      await refreshUser();

      return data;
    } catch (err) {
      console.error('Failed to advance level:', err);
      throw err;
    }
  };

  // Record failure (called on wrong answer)
  const recordFailure = async (healthLost = 1, timeTaken?: number) => {
    try {
      const res = await fetch('/api/quiz/fail', {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ wordId, level, healthLost, timeTaken })
      });
      const data = await res.json();

      setHealth(data.health_remaining);

      // Refresh stats
      const statsRes = await fetch('/api/quiz/stats', {
        headers: getAuthHeaders()
      });
      const statsData = await statsRes.json();
      setStats({
        silkBalance: statsData.silk_balance,
        wordsMastered: statsData.words_mastered,
        quizzesCompleted: statsData.quizzes_completed,
        totalHealthLost: statsData.total_health_lost
      });

      // Refresh user context to update header
      await refreshUser();

      return data;
    } catch (err) {
      console.error('Failed to record failure:', err);
      throw err;
    }
  };

  return {
    level,
    health,
    silk,
    isComplete,
    isLoading,
    stats,
    advance,
    recordFailure
  };
}