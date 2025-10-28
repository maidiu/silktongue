import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';

interface SearchResult {
  id: number;
  word: string;
  part_of_speech: string;
  modern_definition: string;
}

interface SearchBarProps {
  onSearch: (query: string) => void;
}

export default function SearchBar({ onSearch }: SearchBarProps) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [showResults, setShowResults] = useState(false);
  const [loading, setLoading] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(async () => {
      if (query.trim().length > 0) {
        setLoading(true);
        try {
          const res = await fetch(`/api/vocab/search?q=${encodeURIComponent(query)}`);
          const data = await res.json();
          setResults(data);
          setShowResults(true);
        } catch (err) {
          console.error('Search error:', err);
        } finally {
          setLoading(false);
        }
      } else {
        setResults([]);
        setShowResults(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [query]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowResults(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleResultClick = (id: number) => {
    navigate(`/word/${id}`);
    setShowResults(false);
    setQuery('');
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch(query);
    setShowResults(false);
  };

  return (
    <div ref={searchRef} className="relative max-w-md" style={{display:'flex', flexDirection:'row', justifyContent:'center'}}>
      <form onSubmit={handleSubmit}>
        <div className="relative">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search..."
            className="w-full px-4 py-3 bg-black/40 border-2 border-white/10 text-white placeholder-gray-500 focus:border-white/30 transition-all duration-200 outline-none backdrop-blur-sm uppercase tracking-widest text-sm" style={{width: '200px'}}
          />
        </div>
      </form>
      
      {showResults && (
        <div className="absolute top-full mt-2 w-full bg-black/95 backdrop-blur-md border-2 border-white/10 max-h-96 overflow-hidden z-50">
          <div className="overflow-y-auto max-h-96">
            {loading ? (
              <div className="p-6 text-center text-gray-400">
                <span>Searching...</span>
              </div>
            ) : results.length === 0 ? (
              <div className="p-6 text-center">
                <div className="text-gray-500">No results found</div>
              </div>
            ) : (
              <>
                {results.map((result) => (
                  <button
                    key={result.id}
                    onClick={() => handleResultClick(result.id)}
                    className="w-full text-left px-5 py-4 hover:bg-white/5 border-b border-white/10 last:border-b-0 transition-all group"
                  >
                    <div className="flex items-baseline gap-3 mb-1">
                      <span className="font-display font-bold text-white text-lg tracking-wide">
                        {result.word}
                      </span>
                      <span className="text-xs text-gray-400 uppercase tracking-wider">
                        {result.part_of_speech}
                      </span>
                    </div>
                    <div className="text-sm text-gray-400 line-clamp-2">
                      {result.modern_definition}
                    </div>
                  </button>
                ))}
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

