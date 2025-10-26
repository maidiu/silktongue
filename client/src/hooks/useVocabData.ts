import { useState, useEffect } from 'react';
import type { VocabEntry } from '../api/vocab';

interface UseVocabDataParams {
  sort?: 'date' | 'alpha';
  filter?: 'all' | 'learned' | 'unlearned';
  searchQuery?: string;
}

export function useVocabData({ sort = 'date', filter = 'all', searchQuery = '' }: UseVocabDataParams = {}) {
  const [words, setWords] = useState<VocabEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchWords = async () => {
      setLoading(true);
      setError(null);
      
      try {
        const params = new URLSearchParams();
        if (sort) params.append('sort', sort);
        if (filter) params.append('filter', filter);
        
        const res = await fetch(`/api/vocab?${params.toString()}`);
        if (!res.ok) throw new Error('Failed to fetch vocabulary');
        
        let data = await res.json();
        
        // Apply search filter on client side if needed
        if (searchQuery) {
          const query = searchQuery.toLowerCase();
          data = data.filter((word: VocabEntry) => 
            word.word.toLowerCase().includes(query) ||
            word.modern_definition.toLowerCase().includes(query)
          );
        }
        
        setWords(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchWords();
  }, [sort, filter, searchQuery]);

  const refreshData = async () => {
    const params = new URLSearchParams();
    if (sort) params.append('sort', sort);
    if (filter) params.append('filter', filter);
    
    try {
      const res = await fetch(`/api/vocab?${params.toString()}`);
      if (!res.ok) throw new Error('Failed to fetch vocabulary');
      
      let data = await res.json();
      
      // Apply search filter on client side if needed
      if (searchQuery) {
        const query = searchQuery.toLowerCase();
        data = data.filter((word: VocabEntry) => 
          word.word.toLowerCase().includes(query) ||
          word.modern_definition.toLowerCase().includes(query)
        );
      }
      
      setWords(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    }
  };

  return { words, loading, error, refreshData };
}

