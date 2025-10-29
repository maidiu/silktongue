import { useState, useEffect } from 'react';
import { DndContext, useSensor, useSensors, PointerSensor, TouchSensor } from '@dnd-kit/core';
import { arrayMove, SortableContext, verticalListSortingStrategy, useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';

interface StorySequenceProps {
  timePeriods: string[];
  settings: string[];
  turns: string[];
  correctAnswer: string[];
  redHerrings?: {
    timePeriods?: string[];
    settings?: string[];
    turns?: string[];
  };
  isHardMode?: boolean;
  onSuccess?: () => void;
  onFail?: () => void;
}

function SortableItem({ id, content, isCorrect, isWrong, isRedHerring, isExcluded, onToggleExcluded }: { 
  id: string; 
  content: string;
  isCorrect?: boolean;
  isWrong?: boolean;
  isRedHerring?: boolean;
  isExcluded?: boolean;
  onToggleExcluded?: () => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      onDoubleClick={(e) => {
        e.stopPropagation();
        console.log('Double-clicked item:', content);
        onToggleExcluded?.();
      }}
      className={`
        p-3 rounded border-2 cursor-grab active:cursor-grabbing
        select-none transition-all duration-300 text-sm relative
        ${isDragging ? 'opacity-50 shadow-2xl' : ''}
        ${isExcluded ? 'opacity-30 bg-red-900/20 border-red-600/50 line-through text-red-400' : ''}
        ${isCorrect ? 'bg-white/20 border-white/50 shadow-[0_0_20px_rgba(255,255,255,0.3)]' : ''}
        ${isWrong ? 'bg-red-900/40 border-red-500/50' : ''}
        ${isRedHerring ? 'bg-orange-900/40 border-orange-500/50' : ''}
        ${!isCorrect && !isWrong && !isRedHerring && !isExcluded ? 'bg-gray-900/60 border-gray-700 hover:border-gray-600' : ''}
      `}
      title={isExcluded ? "Double-click to include this item" : "Double-click to exclude this item"}
    >
      {content}
    </div>
  );
}

export default function StorySequence({
  timePeriods,
  settings,
  turns,
  correctAnswer,
  redHerrings = {},
  isHardMode = false,
  onSuccess,
  onFail
}: StorySequenceProps) {
  const [timePeriodItems, setTimePeriodItems] = useState<string[]>([]);
  const [settingItems, setSettingItems] = useState<string[]>([]);
  const [turnItems, setTurnItems] = useState<string[]>([]);
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState<'correct' | 'wrong' | null>(null);
  const [excludedItems, setExcludedItems] = useState<Set<string>>(new Set());

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 3,
      },
    }),
    useSensor(TouchSensor, {
      activationConstraint: {
        delay: 0, // Instant response - no delay!
        tolerance: 3,
      },
    })
  );

  useEffect(() => {
    // Shuffle each column independently
    const shuffledTimePeriods = [...timePeriods, ...(redHerrings.timePeriods || [])]
      .sort(() => Math.random() - 0.5);
    const shuffledSettings = [...settings, ...(redHerrings.settings || [])]
      .sort(() => Math.random() - 0.5);
    const shuffledTurns = [...turns, ...(redHerrings.turns || [])]
      .sort(() => Math.random() - 0.5);
    
    setTimePeriodItems(shuffledTimePeriods);
    setSettingItems(shuffledSettings);
    setTurnItems(shuffledTurns);
  }, [timePeriods, settings, turns, redHerrings]);

  const handleDragEnd = (event: any) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const activeId = active.id as string;
    const overId = over.id as string;

    // Determine which column the drag happened in
    if (activeId.startsWith('time-')) {
      setTimePeriodItems((items) => {
        const oldIndex = items.findIndex(item => `time-${item}` === activeId);
        const newIndex = items.findIndex(item => `time-${item}` === overId);
        return arrayMove(items, oldIndex, newIndex);
      });
    } else if (activeId.startsWith('setting-')) {
      setSettingItems((items) => {
        const oldIndex = items.findIndex(item => `setting-${item}` === activeId);
        const newIndex = items.findIndex(item => `setting-${item}` === overId);
        return arrayMove(items, oldIndex, newIndex);
      });
    } else if (activeId.startsWith('turn-')) {
      setTurnItems((items) => {
        const oldIndex = items.findIndex(item => `turn-${item}` === activeId);
        const newIndex = items.findIndex(item => `turn-${item}` === overId);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  const handleSubmit = () => {
    setSubmitted(true);
    
    console.log('Raw correctAnswer:', correctAnswer);
    console.log('correctAnswer type:', typeof correctAnswer);
    console.log('correctAnswer isArray:', Array.isArray(correctAnswer));
    console.log('correctAnswer length:', correctAnswer?.length);
    
    // Parse correct answer to get expected sequences
    // Format: "1st c. CE — Rome → She was born in rhetoric..."
    const expectedSequences = correctAnswer.map(answer => {
      console.log('Processing answer:', answer);
      const [timePart, rest] = answer.split(' — ');
      console.log('  timePart:', timePart, 'rest:', rest);
      if (!rest) {
        console.error('  ERROR: rest is undefined! Cannot split further');
        return { time: '', setting: '', turn: '' };
      }
      const [settingPart, turnPart] = rest.split(' → ');
      console.log('  settingPart:', settingPart, 'turnPart:', turnPart?.substring(0, 50));
      return { time: timePart?.trim(), setting: settingPart?.trim(), turn: turnPart?.trim() };
    });

    // Filter out excluded items
    const filteredTimeItems = timePeriodItems.filter(item => 
      !excludedItems.has(`time-${item}`)
    );
    const filteredSettingItems = settingItems.filter(item => 
      !excludedItems.has(`setting-${item}`)
    );
    const filteredTurnItems = turnItems.filter(item => 
      !excludedItems.has(`turn-${item}`)
    );

    console.log('Raw correctAnswer:', correctAnswer);
    console.log('Expected sequences:', expectedSequences);
    console.log('Filtered time items:', filteredTimeItems);
    console.log('Filtered setting items:', filteredSettingItems);
    console.log('Filtered turn items:', filteredTurnItems);
    
    // Debug: Check each match individually with full details
    filteredTimeItems.forEach((item, idx) => {
      const expected = expectedSequences[idx]?.time;
      const match = item === expected;
      console.log(`Time ${idx}: match=${match}`);
      if (!match) {
        console.log(`  Got:      "${item}" (length: ${item?.length})`);
        console.log(`  Expected: "${expected}" (length: ${expected?.length})`);
      }
    });
    filteredSettingItems.forEach((item, idx) => {
      const expected = expectedSequences[idx]?.setting;
      const match = item === expected;
      console.log(`Setting ${idx}: match=${match}`);
      if (!match) {
        console.log(`  Got:      "${item}" (length: ${item?.length})`);
        console.log(`  Expected: "${expected}" (length: ${expected?.length})`);
      }
    });
    filteredTurnItems.forEach((item, idx) => {
      const expected = expectedSequences[idx]?.turn;
      const match = item === expected;
      console.log(`Turn ${idx}: match=${match}`);
      if (!match) {
        console.log(`  Got:      "${item}"`);
        console.log(`  Expected: "${expected}"`);
        console.log(`  Got length: ${item?.length}, Expected length: ${expected?.length}`);
      }
    });

    // Check if all three columns match the expected order
    const timeMatches = filteredTimeItems.length === expectedSequences.length &&
      filteredTimeItems.every((item, idx) => item === expectedSequences[idx].time);
    const settingMatches = filteredSettingItems.length === expectedSequences.length &&
      filteredSettingItems.every((item, idx) => item === expectedSequences[idx].setting);
    const turnMatches = filteredTurnItems.length === expectedSequences.length &&
      filteredTurnItems.every((item, idx) => item === expectedSequences[idx].turn);

    console.log('Time matches:', timeMatches, 'Setting matches:', settingMatches, 'Turn matches:', turnMatches);

    const passed = timeMatches && settingMatches && turnMatches;
    
    setResult(passed ? 'correct' : 'wrong');
    
    setTimeout(() => {
      if (passed && onSuccess) {
        onSuccess();
      } else if (!passed && onFail) {
        onFail();
        // Reset
        setTimeout(() => {
          const shuffledTimePeriods = [...timePeriods, ...(redHerrings.timePeriods || [])]
            .sort(() => Math.random() - 0.5);
          const shuffledSettings = [...settings, ...(redHerrings.settings || [])]
            .sort(() => Math.random() - 0.5);
          const shuffledTurns = [...turns, ...(redHerrings.turns || [])]
            .sort(() => Math.random() - 0.5);
          
          setTimePeriodItems(shuffledTimePeriods);
          setSettingItems(shuffledSettings);
          setTurnItems(shuffledTurns);
          setSubmitted(false);
          setResult(null);
        }, 2000);
      }
    }, 1500);
  };

  const isCorrectItem = (item: string, type: 'time' | 'setting' | 'turn') => {
    if (!submitted) return false;
    const expectedSequences = correctAnswer.map(answer => {
      const [timePart, rest] = answer.split(' — ');
      const [settingPart, turnPart] = rest.split(' → ');
      return { time: timePart.trim(), setting: settingPart.trim(), turn: turnPart.trim() };
    });
    
    const items = type === 'time' ? timePeriodItems : type === 'setting' ? settingItems : turnItems;
    const index = items.indexOf(item);
    if (index === -1 || index >= expectedSequences.length) return false;
    
    return item === expectedSequences[index][type];
  };

  const isWrongItem = (item: string, type: 'time' | 'setting' | 'turn') => {
    if (!submitted) return false;
    return !isCorrectItem(item, type);
  };

  const isRedHerring = (item: string, type: 'time' | 'setting' | 'turn') => {
    if (type === 'time') return redHerrings.timePeriods?.includes(item) || false;
    if (type === 'setting') return redHerrings.settings?.includes(item) || false;
    if (type === 'turn') return redHerrings.turns?.includes(item) || false;
    return false;
  };

  const toggleExcluded = (item: string, type: 'time' | 'setting' | 'turn') => {
    console.log('toggleExcluded called with:', item, type);
    const itemKey = `${type}-${item}`;
    setExcludedItems(prev => {
      console.log('Previous excluded items:', Array.from(prev));
      const newSet = new Set(prev);
      if (newSet.has(itemKey)) {
        newSet.delete(itemKey);
        console.log('Removed from excluded:', itemKey);
      } else {
        newSet.add(itemKey);
        console.log('Added to excluded:', itemKey);
      }
      console.log('New excluded items:', Array.from(newSet));
      return newSet;
    });
  };

  return (
    <LevelScene
      title={isHardMode ? "VI. Trial of Chaos" : "V. Story — Integration"}
      instruction={
        isHardMode 
          ? "Rebuild the full story—beware the false centuries. Conquer for double silk."
          : "Order the word's history into sense. Trace how it lived through time."
      }
    >
      <div className="flex flex-col items-center mt-8 gap-6">
        {isHardMode && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-orange-400 font-display text-sm uppercase tracking-wider mb-4"
          >
            ⚠ Hard Mode — Remove All False Entries
          </motion.div>
        )}
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-gray-400 text-sm mb-6 max-w-4xl mx-auto text-center"
        >
          {isHardMode ? (
            <>
              <div className="mb-2">Some items are false entries (red herrings).</div>
              <div><span className="text-orange-400">Double-click</span> to exclude items you think are wrong. <span className="text-gray-400">Click and drag</span> to rearrange.</div>
            </>
          ) : (
            "Arrange the story elements in chronological order."
          )}
        </motion.div>

        <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
          <div className="w-full max-w-6xl">
            <div className={`grid gap-6 ${settings.length > 0 ? 'grid-cols-3' : 'grid-cols-2'}`}>
              {/* Time Periods Column */}
              <div className="space-y-4">
                <h3 className="text-center text-gray-400 font-display text-sm uppercase tracking-wider">
                  Time Periods
                </h3>
                <SortableContext 
                  items={timePeriodItems.map(item => `time-${item}`)} 
                  strategy={verticalListSortingStrategy}
                >
                  <div className="space-y-3">
                    {timePeriodItems.map((item, idx) => (
                      <div key={`time-${item}`} className="flex items-center gap-3">
                        <div className="text-gray-500 font-display text-sm w-6 text-right">
                          {idx + 1}
                        </div>
                        <div className="flex-1">
                          <SortableItem 
                            id={`time-${item}`} 
                            content={item}
                            isCorrect={isCorrectItem(item, 'time')}
                            isWrong={isWrongItem(item, 'time')}
                            isRedHerring={isRedHerring(item, 'time')}
                            isExcluded={excludedItems.has(`time-${item}`)}
                            onToggleExcluded={() => toggleExcluded(item, 'time')}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </SortableContext>
              </div>

              {/* Settings Column - only show if we have settings */}
              {settings.length > 0 && (
                <div className="space-y-4">
                  <h3 className="text-center text-gray-400 font-display text-sm uppercase tracking-wider">
                    Cultural Settings
                  </h3>
                  <SortableContext 
                    items={settingItems.map(item => `setting-${item}`)} 
                    strategy={verticalListSortingStrategy}
                  >
                    <div className="space-y-3">
                      {settingItems.map((item, idx) => (
                        <div key={`setting-${item}`} className="flex items-center gap-3">
                          <div className="text-gray-500 font-display text-sm w-6 text-right">
                            {idx + 1}
                          </div>
                          <div className="flex-1">
                            <SortableItem 
                              id={`setting-${item}`} 
                              content={item}
                              isCorrect={isCorrectItem(item, 'setting')}
                              isWrong={isWrongItem(item, 'setting')}
                              isRedHerring={isRedHerring(item, 'setting')}
                              isExcluded={excludedItems.has(`setting-${item}`)}
                              onToggleExcluded={() => toggleExcluded(item, 'setting')}
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  </SortableContext>
                </div>
              )}

              {/* Story Events Column */}
              <div className="space-y-4">
                <h3 className="text-center text-gray-400 font-display text-sm uppercase tracking-wider">
                  Story Events
                </h3>
                <SortableContext 
                  items={turnItems.map(item => `turn-${item}`)} 
                  strategy={verticalListSortingStrategy}
                >
                  <div className="space-y-3">
                    {turnItems.map((item, idx) => (
                      <div key={`turn-${item}`} className="flex items-center gap-3">
                        <div className="text-gray-500 font-display text-sm w-6 text-right">
                          {idx + 1}
                        </div>
                        <div className="flex-1">
                          <SortableItem 
                            id={`turn-${item}`} 
                            content={item}
                            isCorrect={isCorrectItem(item, 'turn')}
                            isWrong={isWrongItem(item, 'turn')}
                            isRedHerring={isRedHerring(item, 'turn')}
                            isExcluded={excludedItems.has(`turn-${item}`)}
                            onToggleExcluded={() => toggleExcluded(item, 'turn')}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </SortableContext>
              </div>
            </div>
          </div>
        </DndContext>

        {!submitted && (
          <motion.button
            onClick={handleSubmit}
            className="px-8 py-3 bg-white/10 text-white rounded border-2 border-white/30
                     hover:bg-white/20 hover:border-white/50 transition-all duration-300
                     font-display uppercase tracking-wider"
          >
            Submit Sequence
          </motion.button>
        )}

        {result && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            {result === 'correct' ? (
              <div className="text-white text-xl font-display">
                {isHardMode 
                  ? '⚔ You have slain the beast of confusion' 
                  : '✓ The centuries fall into place—the word lives again'
                }
              </div>
            ) : (
              <div className="text-red-400 text-xl font-display">
                {isHardMode
                  ? '✗ The beast devoured your certainty'
                  : '✗ Some centuries landed out of time'
                }
              </div>
            )}
          </motion.div>
        )}
      </div>
    </LevelScene>
  );
}

