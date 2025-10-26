import { useState } from 'react';
import Layout from '../components/Layout/Layout';
import SortFilter from '../components/Filters/SortFilter';
import VocabList from '../components/Lists/VocabList';
import Loader from '../components/Shared/Loader';
import StatsDisplay from '../components/Shared/StatsDisplay';
import Scoreboard from '../components/Shared/Scoreboard';
import { useVocabData } from '../hooks/useVocabData';

export default function HomePage() {
  const [sortBy, setSortBy] = useState<'date' | 'alpha'>('date');
  const [filterBy, setFilterBy] = useState<'all' | 'learned' | 'unlearned'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  const { words, loading, error, refreshData } = useVocabData({
    sort: sortBy,
    filter: filterBy,
    searchQuery,
  });

  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  // Filter out stub entries (words without definitions)
  const completeWords = words.filter(w => w.modern_definition && w.modern_definition.trim());

  return (
    <Layout onSearch={handleSearch}>
      <div className="space-y-4 sm:space-y-6 lg:space-y-8">
        {/* Header Section */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 sm:gap-6 py-6 sm:py-8 lg:py-12 border-b-2 border-white/15 relative">
          {/* Ornate header decorations */}
          <div className="absolute -bottom-1 left-0 w-24 h-0.5 bg-white/20"></div>
          <div className="absolute -bottom-1 right-0 w-24 h-0.5 bg-white/20"></div>
          <div className="absolute -bottom-0.5 left-1/2 transform -translate-x-1/2 w-16 h-0.5 bg-white/10"></div>
          
          <div className="relative">
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-bold text-white tracking-wider mb-2 sm:mb-3 relative">
              VOCABULARY
              {/* Decorative underline */}
              <div className="absolute -bottom-2 left-0 w-full h-0.5 bg-white/20"></div>
              <div className="absolute -bottom-1 left-1/4 w-1/2 h-0.5 bg-white/10"></div>
            </h2>
            <p className="text-gray-400 text-xs sm:text-sm uppercase tracking-widest ml-2">
              {completeWords.length} {completeWords.length === 1 ? 'Entry' : 'Entries'}
            </p>
          </div>
          
          <div>
            <SortFilter
              sortBy={sortBy}
              filterBy={filterBy}
              onSortChange={setSortBy}
              onFilterChange={setFilterBy}
            />
          </div>
        </div>

        {loading ? (
          <Loader />
        ) : error ? (
          <div className="text-center py-16">
            <div className="text-gray-600 text-lg uppercase tracking-widest mb-2">Error</div>
            <div className="text-gray-400 text-sm">{error}</div>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
            {/* Main Content */}
            <div className="lg:col-span-3">
              <VocabList 
                entries={completeWords} 
              />
            </div>
            
            {/* Sidebar */}
            <div className="space-y-6">
              <StatsDisplay />
              <Scoreboard />
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}

