import VocabCard from '../VocabCard/VocabCard';
import type { VocabEntry } from '../../api/vocab';

interface VocabListProps {
  entries: VocabEntry[];
}

export default function VocabList({ entries }: VocabListProps) {
  if (entries.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-400 text-lg">No vocabulary entries found.</p>
      </div>
    );
  }

  return (
    <div>
      {entries.map((entry, index) => (
        <div key={entry.id} className={index > 0 ? "mt-12" : ""}>
          <VocabCard
            entry={entry}
          />
        </div>
      ))}
    </div>
  );
}

