import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Layout from '../components/Layout/Layout';
import VocabCard from '../components/VocabCard/VocabCard';
import Loader from '../components/Shared/Loader';
import type { VocabEntry } from '../api/vocab';

export default function WordDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [word, setWord] = useState<VocabEntry | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [quizProgress, setQuizProgress] = useState<any>(null);
  const [checkingQuiz, setCheckingQuiz] = useState(true);

  useEffect(() => {
    const fetchWord = async () => {
      if (!id) return;
      
      setLoading(true);
      setError(null);
      
      try {
        const res = await fetch(`/api/vocab/${id}`);
        if (!res.ok) {
          if (res.status === 404) {
            setError('Word not found');
          } else {
            throw new Error('Failed to fetch word');
          }
          return;
        }
        
        const data = await res.json();
        setWord(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchWord();
  }, [id]);

  useEffect(() => {
    const checkQuizProgress = async () => {
      if (!id) return;
      
      try {
        const token = localStorage.getItem('token');
        const res = await fetch(`/api/quiz/progress/${id}`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (res.ok) {
          const progress = await res.json();
          setQuizProgress(progress);
        }
      } catch (err) {
        console.error('Failed to check quiz progress:', err);
      } finally {
        setCheckingQuiz(false);
      }
    };

    checkQuizProgress();
  }, [id]);

  const handleLearnedToggle = async (wordId: number, isMastered: boolean) => {
    try {
      const res = await fetch(`/api/vocab/${wordId}/learned`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_mastered: isMastered }),
      });
      
      if (!res.ok) throw new Error('Failed to update learned status');
      
      // Update local state
      if (word) {
        setWord({ ...word, is_mastered: isMastered });
      }
    } catch (err) {
      console.error('Error toggling learned status:', err);
    }
  };

  // If there's an active quiz, show lock-in message
  if (quizProgress && !quizProgress.completed_at) {
    return (
      <Layout>
        <div className="max-w-4xl mx-auto">
          <button
            onClick={() => navigate(-1)}
            className="mb-6 text-blue-600 hover:text-blue-800 flex items-center gap-1"
          >
            ← Back
          </button>

          <div className="text-center py-16">
            <div className="text-orange-400 text-6xl mb-6">🔒</div>
            <h2 className="text-2xl font-display font-bold text-white mb-4">
              Quiz Locked In
            </h2>
            <p className="text-gray-400 mb-8 max-w-md mx-auto">
              You've started a quiz for this word. You must complete it or fail before you can return to study the details.
            </p>
            <div className="bg-gray-800/50 p-6 rounded-lg border border-gray-700 max-w-md mx-auto mb-8">
              <div className="text-sm text-gray-400 mb-2">Current Progress:</div>
              <div className="text-white font-display">
                Level {quizProgress.current_level} of 5
              </div>
              <div className="text-gray-400 text-sm mt-2">
                Health: {'❤️'.repeat(quizProgress.health_remaining)}
              </div>
            </div>
            <button
              onClick={() => navigate(`/quiz/${id}`)}
              className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30 hover:bg-white/20 hover:border-white/50 transition-all duration-300 font-display uppercase tracking-wider"
            >
              Continue Quiz
            </button>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="max-w-4xl mx-auto">
        <button
          onClick={() => navigate(-1)}
          className="mb-6 text-blue-600 hover:text-blue-800 flex items-center gap-1"
        >
          ← Back
        </button>

        {loading || checkingQuiz ? (
          <Loader />
        ) : error ? (
          <div className="text-center py-12">
            <p className="text-red-500 text-lg mb-4">Error: {error}</p>
            <button
              onClick={() => navigate('/')}
              className="text-blue-600 hover:text-blue-800"
            >
              Go to homepage
            </button>
          </div>
        ) : word ? (
          <VocabCard entry={word} onLearnedToggle={handleLearnedToggle} />
        ) : null}
      </div>
    </Layout>
  );
}

