import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { formatCentury } from '../../utils/ordinals';

interface TimelineEvent {
  id: number;
  century?: string;
  year?: number;
  sense_at_time?: string;
  sibling_words?: string[];
  cultural_context?: string;
  causal_tensions?: string;
  language_transitions?: string;
  event_text: string;
  causal_tags?: string[];
}

interface Relation {
  id: number;
  word: string;
  modern_definition: string;
  relation_type: string;
}

interface Root {
  root_word: string;
  language: string;
  meaning: string;
}

interface DetailedEntry {
  id: number;
  word: string;
  contrastive_opening?: string;
  structural_analysis?: string;
  timeline_events: TimelineEvent[];
  relations: Relation[];
  roots: Root[];
}

interface StoryPanelProps {
  entryId: number;
}

export default function StoryPanel({ entryId }: StoryPanelProps) {
  const [data, setData] = useState<DetailedEntry | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const res = await fetch(`/api/vocab/${entryId}`);
        if (!res.ok) throw new Error('Failed to load details');
        const data = await res.json();
        setData(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchDetails();
  }, [entryId]);

  if (loading) {
    return (
      <div className="p-6 text-center text-silk-400">
        <span className="inline-block animate-pulse-slow">✦</span> Unraveling the chronicle...
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="p-6 text-center text-shade-300">
        {error || 'The threads have yet to be woven...'}
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Contrastive Opening */}
      {data.contrastive_opening && (
        <div className="prose max-w-none">
          <div className="bg-shade-900/40 border-l-4 border-shade-500 p-4 rounded-lg backdrop-blur-sm">
            <h4 className="text-sm font-serif font-semibold text-shade-200 mb-2">
              ✦ Threshold
            </h4>
            <p className="text-silk-200 leading-relaxed">{data.contrastive_opening}</p>
          </div>
        </div>
      )}

      {/* Timeline Events */}
      {data.timeline_events && data.timeline_events.length > 0 && (
        <div>
          <h4 className="text-lg font-serif font-semibold text-soul-300 mb-4 flex items-center gap-2">
            <span className="text-soul-400">✦</span> Chronicle Through Time
          </h4>
          <div className="space-y-4">
            {data.timeline_events.map((event) => (
              <div
                key={event.id}
                className="border-l-4 border-soul-600/40 pl-4 py-2 hover:border-soul-500 transition-colors"
              >
                <div className="flex flex-wrap items-baseline gap-2 mb-2">
                  <span className="text-sm font-serif font-bold text-soul-200">
                    {event.century && formatCentury(event.century)}
                    {event.year && ` (${event.year})`}
                  </span>
                  {event.causal_tags && event.causal_tags.length > 0 && (
                    <div className="flex gap-1 flex-wrap">
                      {event.causal_tags.map((tag, i) => (
                        <span
                          key={i}
                          className="text-xs px-2 py-0.5 bg-shade-800/60 text-shade-200 rounded border border-shade-600/40"
                        >
                          {tag.replace(/_/g, ' ')}
                        </span>
                      ))}
                    </div>
                  )}
                </div>

                {event.sense_at_time && (
                  <p className="text-sm text-silk-300 mb-2">
                    <span className="font-medium text-soul-400">Essence:</span> {event.sense_at_time}
                  </p>
                )}

                <p className="text-silk-200 mb-2 leading-relaxed">{event.event_text}</p>

                {event.sibling_words && event.sibling_words.length > 0 && (
                  <p className="text-sm text-silk-400">
                    <span className="font-medium text-silk-300">Kindred words:</span>{' '}
                    {event.sibling_words.join(', ')}
                  </p>
                )}

                {event.language_transitions && (
                  <p className="text-sm text-silk-400 italic mt-1">
                    {event.language_transitions}
                  </p>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Structural Analysis */}
      {data.structural_analysis && (
        <div className="bg-soul-900/20 border-l-4 border-soul-500/60 p-4 rounded-lg backdrop-blur-sm">
          <h4 className="text-sm font-serif font-semibold text-soul-200 mb-2">
            ✦ Pattern Analysis
          </h4>
          <p className="text-silk-200 leading-relaxed">{data.structural_analysis}</p>
        </div>
      )}

      {/* Word Relations */}
      {data.relations && data.relations.length > 0 && (
        <div>
          <h4 className="text-sm font-serif font-semibold text-silk-200 mb-3">
            Bound Threads
          </h4>
          <div className="flex flex-wrap gap-2">
            {data.relations.map((rel) => (
              <Link
                key={rel.id}
                to={`/word/${rel.id}`}
                className="px-3 py-1.5 bg-void-200/60 hover:bg-void-200/80 border border-silk-800/40 hover:border-soul-500/50 text-silk-200 rounded-lg text-sm transition-all hover:shadow-glow"
                title={rel.modern_definition}
              >
                {rel.word} <span className="text-xs text-silk-400">({rel.relation_type})</span>
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Root Families */}
      {data.roots && data.roots.length > 0 && (
        <div>
          <h4 className="text-sm font-serif font-semibold text-silk-200 mb-3">
            Ancient Roots
          </h4>
          <div className="space-y-2">
            {data.roots.map((root, i) => (
              <p key={i} className="text-sm text-silk-300">
                <span className="font-mono font-medium text-soul-300">{root.root_word}</span>
                {' '}<span className="text-silk-400">({root.language})</span> — <span className="text-silk-200">{root.meaning}</span>
              </p>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

