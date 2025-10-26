import { useState, useEffect } from 'react';
import type { VocabEntry } from '../api/vocab';

interface UseExploreDataParams {
  century?: string;
  tag?: string;
}

export function useExploreData({ century = '', tag = '' }: UseExploreDataParams = {}) {
  const [words, setWords] = useState<VocabEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchWords = async () => {
      setLoading(true);
      setError(null);
      
      try {
        const params = new URLSearchParams();
        if (century) params.append('century', century);
        if (tag) params.append('tag', tag);
        
        const res = await fetch(`/api/explore?${params.toString()}`);
        if (!res.ok) throw new Error('Failed to fetch vocabulary');
        
        const data = await res.json();
        setWords(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    // Only fetch if at least one filter is selected
    if (century || tag) {
      fetchWords();
    } else {
      setWords([]);
      setLoading(false);
    }
  }, [century, tag]);

  const toggleLearned = async (id: number, isMastered: boolean) => {
    try {
      const res = await fetch(`/api/vocab/${id}/learned`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_mastered: isMastered }),
      });
      
      if (!res.ok) throw new Error('Failed to update learned status');
      
      // Update local state
      setWords(prev => 
        prev.map(word => 
          word.id === id ? { ...word, is_mastered: isMastered } : word
        )
      );
    } catch (err) {
      console.error('Error toggling learned status:', err);
      throw err;
    }
  };

  return { words, loading, error, toggleLearned };
}

