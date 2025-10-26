import { useState } from 'react';
import Layout from '../components/Layout/Layout';
import TagCenturyFilter from '../components/Filters/TagCenturyFilter';
import VocabList from '../components/Lists/VocabList';
import Loader from '../components/Shared/Loader';
// import EmptyState from '../components/Shared/EmptyState';
import { useExploreData } from '../hooks/useExploreData';

export default function ExplorerPage() {
  const [selectedCentury, setSelectedCentury] = useState('');
  const [selectedTag, setSelectedTag] = useState('');

  const { words, loading, error, toggleLearned } = useExploreData({
    century: selectedCentury,
    tag: selectedTag,
  });

  // Filter out stub entries (words without definitions)
  const completeWords = words.filter(w => w.modern_definition && w.modern_definition.trim());

  return (
    <Layout>
      <div className="space-y-8" style={{gap:'1rem'}}>
        {/* Header Section */}
        <div className="py-8 border-b-2 border-white/10">
          <h2 className="text-4xl font-display font-bold text-white tracking-wider mb-4">
            EXPLORER
          </h2>
          <p className="text-gray-400 text-sm mb-6 uppercase tracking-widest">
            Discover words by century and pattern
          </p>

          <TagCenturyFilter
            selectedCentury={selectedCentury}
            selectedTag={selectedTag}
            onCenturyChange={setSelectedCentury}
            onTagChange={setSelectedTag}
          />
        </div>

        {loading ? (
          <Loader />
        ) : error ? (
          <div className="text-center py-16">
            <div className="text-gray-600 text-lg uppercase tracking-widest mb-2">Error</div>
            <div className="text-gray-400 text-sm">{error}</div>
          </div>
        ) : !selectedCentury && !selectedTag ? (
          <div className="text-center py-16">
            <div className="text-gray-500 text-sm uppercase tracking-widest">
              Select a century or pattern above
            </div>
          </div>
        ) : (
          <div>
            <div className="mb-6 text-gray-400 text-sm uppercase tracking-widest">
              {completeWords.length} {completeWords.length === 1 ? 'Entry' : 'Entries'} Found
            </div>
            <VocabList entries={completeWords} onLearnedToggle={toggleLearned} />
          </div>
        )}
      </div>
    </Layout>
  );
}

