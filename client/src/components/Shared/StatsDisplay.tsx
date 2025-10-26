import { useState, useEffect } from 'react';
import type { UserStats } from '../../api/vocab';
import { getUserStats } from '../../api/vocab';

export default function StatsDisplay() {
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await getUserStats();
        setStats(data);
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="bg-gray-800/30 p-6 rounded-lg border border-gray-700">
        <div className="text-gray-400 text-sm">Loading statistics...</div>
      </div>
    );
  }

  if (!stats) {
    return null;
  }

  return (
    <div className="bg-gray-800/30 p-6 rounded-lg border border-gray-700">
      <h3 className="text-lg font-display font-bold text-white mb-4 uppercase tracking-wider">
        Progress Statistics
      </h3>
      <div className="grid grid-cols-3 gap-4">
        <div className="text-center">
          <div className="text-2xl font-bold text-blue-400">{stats.learned_count}</div>
          <div className="text-sm text-gray-400 uppercase tracking-wider">Learned</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-green-400">{stats.mastered_count}</div>
          <div className="text-sm text-gray-400 uppercase tracking-wider">Mastered</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-400">{stats.total_words}</div>
          <div className="text-sm text-gray-400 uppercase tracking-wider">Total</div>
        </div>
      </div>
    </div>
  );
}
