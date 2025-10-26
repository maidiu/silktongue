import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import StoryPanel from './StoryPanel';
import type { VocabEntry, BeastModeStatus } from '../../api/vocab';
import { getBeastModeStatus } from '../../api/vocab';

interface VocabCardProps {
  entry: VocabEntry;
}

export default function VocabCard({ entry }: VocabCardProps) {
  const [revealLevel, setRevealLevel] = useState<number>(0); // 0: word, 1: +definition/POS, 2: +details, 3: +story
  const [beastModeStatus, setBeastModeStatus] = useState<BeastModeStatus | null>(null);
  const [isLoadingBeastMode, setIsLoadingBeastMode] = useState(false);
  const [cooldownTimeLeft, setCooldownTimeLeft] = useState<string>('');
  const navigate = useNavigate();

  useEffect(() => {
    const fetchBeastModeStatus = async () => {
      try {
        const status = await getBeastModeStatus(entry.id);
        setBeastModeStatus(status);
      } catch (error) {
        console.error('Failed to fetch beast mode status:', error);
      }
    };

    fetchBeastModeStatus();
  }, [entry.id]);

  // Countdown timer effect
  useEffect(() => {
    if (beastModeStatus?.status === 'cooldown' && beastModeStatus.cooldown_until) {
      const updateCountdown = () => {
        const now = new Date().getTime();
        const cooldownTime = new Date(beastModeStatus.cooldown_until!).getTime();
        const difference = cooldownTime - now;

        if (difference > 0) {
          const hours = Math.floor(difference / (1000 * 60 * 60));
          const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
          const seconds = Math.floor((difference % (1000 * 60)) / 1000);
          setCooldownTimeLeft(`${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`);
        } else {
          setCooldownTimeLeft('00:00:00');
          // Refresh the beast mode status when cooldown ends
          const refreshStatus = async () => {
            try {
              const status = await getBeastModeStatus(entry.id);
              setBeastModeStatus(status);
            } catch (error) {
              console.error('Failed to refresh beast mode status:', error);
            }
          };
          refreshStatus();
        }
      };

      updateCountdown();
      const interval = setInterval(updateCountdown, 1000);
      return () => clearInterval(interval);
    }
  }, [beastModeStatus?.cooldown_until, entry.id]);

  const handleStartQuiz = () => {
    navigate(`/quiz/${entry.id}`);
  };

  const handleBeastMode = () => {
    navigate(`/quiz/${entry.id}?level=6`);
  };

  const getStatusDisplay = () => {
    switch (entry.learning_status) {
      case 'learned':
        return [{ text: 'LEARNED', color: 'text-blue-400', bg: 'bg-blue-900/20', border: 'border-blue-500/30' }];
      case 'mastered':
        return [
          { text: 'LEARNED', color: 'text-blue-400', bg: 'bg-blue-900/20', border: 'border-blue-500/30' },
          { text: 'MASTERED', color: 'text-green-400', bg: 'bg-green-900/20', border: 'border-green-500/30' }
        ];
      default:
        return [{ text: 'UNMASTERED', color: 'text-gray-400', bg: 'bg-gray-800/20', border: 'border-gray-600/30' }];
    }
  };

  return (
    <div className="backdrop-blur-sm transition-all duration-300 overflow-hidden group relative shadow-xl rounded-lg" style={{backgroundColor: '#3d1e3d', opacity: 0.8, borderTop: 0, marginBottom: '2rem'}}>
      {/* CEFR Level Badge - Bottom Right Corner */}
      {entry.cefr_level && (
        <div className="absolute bottom-4 right-4 z-10">
          <span className="text-xs px-2 py-1 bg-white/5 text-gray-300">
            {entry.cefr_level}
          </span>
        </div>
      )}
      
      {/* Collapsed View */}
      <div className="p-8 relative">
        <div className="flex items-start justify-between gap-6">
          <div className="flex-1" style={{padding:'0 1rem 0 1rem'}}>
            <div className="flex items-baseline gap-4 mb-4">
              <h3 className="text-3xl font-display font-bold text-white tracking-wide">
                {entry.word}
              </h3>
              {revealLevel >= 1 && (
                <span className="text-sm text-gray-100 italic font-light uppercase tracking-wider">
                  <br></br>{entry.part_of_speech}
                </span>
              )}
            </div>
            
            {revealLevel >= 1 && (
              <p className="text-gray-200 mb-4 leading-relaxed text-lg">{entry.modern_definition}</p>
            )}
            
            {revealLevel >= 2 && entry.usage_example && (
              <p className="text-sm text-gray-400 italic mb-4 pl-6">
                {entry.usage_example}
              </p>
            )}

            {revealLevel >= 2 && (
              <div className="space-y-4 text-sm text-gray-300">
                {/* Definitions 1,2,3 */}
                {entry.definitions && (
                  <div className="space-y-1">
                    {entry.definitions.primary && (<div>1. {entry.definitions.primary}</div>)}
                    {entry.definitions.secondary && (<div>2. {entry.definitions.secondary}</div>)}
                    {entry.definitions.tertiary && (<div>3. {entry.definitions.tertiary}</div>)}
                  </div>
                )}

                {/* Usage example was rendered above */}

                {/* Common collocations */}
                {entry.common_collocations && entry.common_collocations.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Common collocations: </span>
                    <span>{entry.common_collocations.join(', ')}</span>
                  </div>
                )}

                {/* Variant forms */}
                {entry.variant_forms && entry.variant_forms.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Variant forms: </span>
                    <span>{entry.variant_forms.join(', ')}</span>
                  </div>
                )}

                {/* Synonyms */}
                {entry.synonyms && entry.synonyms.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Synonyms: </span>
                    <span>{entry.synonyms.join(', ')}</span>
                  </div>
                )}

                {/* Antonyms */}
                {entry.antonyms && entry.antonyms.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Antonyms: </span>
                    <span>{entry.antonyms.join(', ')}</span>
                  </div>
                )}

                {/* French equivalent and lists */}
                {entry.french_equivalent && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">FR: </span>
                    <span>{entry.french_equivalent}</span>
                  </div>
                )}
                {entry.french_synonyms && entry.french_synonyms.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">French synonyms: </span>
                    <span>{entry.french_synonyms.join(', ')}</span>
                  </div>
                )}
                {entry.french_root_cognates && entry.french_root_cognates.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">French root cognates: </span>
                    <span>{entry.french_root_cognates.join(', ')}</span>
                  </div>
                )}

                {/* Russian equivalent and lists */}
                {entry.russian_equivalent && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">RU: </span>
                    <span>{entry.russian_equivalent}</span>
                  </div>
                )}
                {entry.russian_synonyms && entry.russian_synonyms.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Russian synonyms: </span>
                    <span>{entry.russian_synonyms.join(', ')}</span>
                  </div>
                )}
                {entry.russian_root_cognates && entry.russian_root_cognates.length > 0 && (
                  <div>
                    <span className="uppercase tracking-widest text-gray-400">Russian root cognates: </span>
                    <span>{entry.russian_root_cognates.join(', ')}</span>
                  </div>
                )}
              </div>
            )}
          </div>

                {/* Status Badges */}
                <div className="flex-shrink-0 flex gap-2">
                  {getStatusDisplay().map((status, index) => (
                    <div key={index} className={`px-4 py-2 rounded-lg border ${status.bg} ${status.border}`}>
                      <span className={`text-sm font-display uppercase tracking-wider ${status.color}`}>
                        {status.text}
                      </span>
                    </div>
                  ))}
                </div>
        </div>

              <div className="mt-6 pt-6 border-t border-gray-700">
                <div className="flex flex-wrap gap-3 items-center justify-between">
                  <div className="flex flex-wrap gap-3">
                    <button
                      onClick={() => setRevealLevel(0)}
                      aria-pressed={revealLevel === 0}
                      className={`px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300 ${
                        revealLevel === 0
                          ? 'text-white border border-white/20'
                          : 'text-gray-400 hover:text-white border border-white/10 hover:border-white/20'
                      }`}
                    >
                      Word
                    </button>
                    <button
                      onClick={() => setRevealLevel(1)}
                      aria-pressed={revealLevel === 1}
                      className={`px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300 ${
                        revealLevel === 1
                          ? 'text-white border border-white/20'
                          : 'text-gray-400 hover:text-white border border-white/10 hover:border-white/20'
                      }`}
                    >
                      Definition
                    </button>
                    <button
                      onClick={() => setRevealLevel(2)}
                      aria-pressed={revealLevel === 2}
                      className={`px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300 ${
                        revealLevel === 2
                          ? 'text-white border border-white/20'
                          : 'text-gray-400 hover:text-white border border-white/10 hover:border-white/20'
                      }`}
                    >
                      Details
                    </button>
                    <button
                      onClick={() => setRevealLevel(3)}
                      aria-pressed={revealLevel === 3}
                      className={`px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300 ${
                        revealLevel === 3
                          ? 'text-white border border-white/20'
                          : 'text-gray-400 hover:text-white border border-white/10 hover:border-white/20'
                      }`}
                    >
                      Story
                    </button>
                  </div>
                  
                  <div className="flex gap-3">
                    <button
                      onClick={handleStartQuiz}
                      className="px-4 py-2 text-xs uppercase tracking-widest transition-all duration-300
                               bg-white/10 text-white border border-white/30 hover:bg-white/20 hover:border-white/50"
                    >
                      ⚔ Test Mastery
                    </button>
                    
                    {/* Beast Mode Button */}
                    {beastModeStatus?.status === 'available' && (
                      <button
                        onClick={handleBeastMode}
                        className="px-4 py-2 text-xs uppercase tracking-widest transition-all duration-300
                                 bg-orange-600/20 text-orange-400 border border-orange-500/30 hover:bg-orange-600/30 hover:border-orange-500/50"
                      >
                        🔥 Beast Mode
                      </button>
                    )}
                    
                    {beastModeStatus?.status === 'cooldown' && (
                      <div className="px-4 py-2 text-xs uppercase tracking-widest
                                   bg-orange-900/20 text-orange-400 border border-orange-500/30">
                        🔥 Cooldown: {cooldownTimeLeft || 'Loading...'}
                      </div>
                    )}
                  </div>
                </div>
              </div>
      </div>

      {/* Expanded View */}
      {revealLevel >= 3 && (
        <div className="border-t-2 border-white/10">
          <StoryPanel entryId={entry.id} />
        </div>
      )}
    </div>
  );
}

