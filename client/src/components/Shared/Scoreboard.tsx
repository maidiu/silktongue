import { useState, useEffect } from 'react';
import type { ScoreboardEntry } from '../../api/vocab';
import { getScoreboard } from '../../api/vocab';

export default function Scoreboard() {
  const [scoreboard, setScoreboard] = useState<ScoreboardEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchScoreboard = async () => {
      try {
        const data = await getScoreboard();
        setScoreboard(data);
      } catch (error) {
        console.error('Failed to fetch scoreboard:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchScoreboard();
  }, []);

  if (loading) {
    return (
      <div className="bg-gray-800/30 p-6 rounded-lg border border-gray-700">
        <div className="text-gray-400 text-sm">Loading scoreboard...</div>
      </div>
    );
  }

  if (scoreboard.length === 0) {
    return (
      <div className="bg-gray-800/30 p-6 rounded-lg border border-gray-700">
        <h3 className="text-lg font-display font-bold text-white mb-4 uppercase tracking-wider">
          Leaderboard
        </h3>
        <div className="text-gray-400 text-sm">No scores available yet.</div>
      </div>
    );
  }

  return (
    <div className="bg-gray-800/30 p-6 rounded-lg border border-gray-700">
      <h3 className="text-lg font-display font-bold text-white mb-4 uppercase tracking-wider">
        Leaderboard
      </h3>
      <div className="space-y-3">
        {scoreboard.map((entry, index) => (
          <div key={entry.username} className="flex items-center justify-between py-2 px-3 bg-gray-700/30 rounded">
            <div className="flex flex-col gap-1">
              <div className="text-white font-medium">
                <span className="text-lg font-bold text-orange-400">{index + 1}.</span> {entry.username}
              </div>
              <div className="text-xs text-gray-400 ml-7">
                {entry.words_learned} learned • {entry.words_mastered} mastered
              </div>
            </div>
            <div className="text-right">
              <div className="text-orange-400 font-bold">{entry.total_silk_earned} silk</div>
              <div className="text-xs text-gray-400">{entry.quizzes_completed} quizzes</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
