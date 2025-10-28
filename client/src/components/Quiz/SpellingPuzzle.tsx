import { useState, useEffect } from 'react';
import { DndContext, closestCenter, useSensor, useSensors, PointerSensor, TouchSensor, KeyboardSensor } from '@dnd-kit/core';
import { arrayMove, SortableContext, sortableKeyboardCoordinates, horizontalListSortingStrategy } from '@dnd-kit/sortable';
import { SortableItem } from './SortableItem';
import { motion } from 'framer-motion';
import LevelScene from './LevelScene';

interface SpellingPuzzleProps {
  word: string;
  onSuccess?: () => void;
}

export default function SpellingPuzzle({ word, onSuccess }: SpellingPuzzleProps) {
  const letters = word.toUpperCase().split('');
  const [items, setItems] = useState<string[]>([]);
  const [isCorrect, setIsCorrect] = useState(false);

  useEffect(() => {
    // Create unique IDs for each letter position
    const shuffled = [...letters].sort(() => Math.random() - 0.5);
    const itemsWithIds = shuffled.map((letter, index) => `${letter}-${index}`);
    setItems(itemsWithIds);
  }, [word]);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // 8px of movement required before drag starts
      },
    }),
    useSensor(TouchSensor, {
      activationConstraint: {
        delay: 200, // 200ms press before drag starts (prevents conflict with scrolling)
        tolerance: 8, // Allow 8px of movement during the delay
      },
    }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
  );

  const handleDragEnd = (event: any) => {
    const { active, over } = event;
    
    if (!over || active.id === over.id) return;
    
    setItems((items) => {
      const oldIndex = items.indexOf(active.id);
      const newIndex = items.indexOf(over.id);
      const newOrder = arrayMove(items, oldIndex, newIndex);

      // Check if correct - extract just the letters from the IDs
      const currentLetters = newOrder.map(item => item.split('-')[0]);
      if (currentLetters.join('') === letters.join('')) {
        setIsCorrect(true);
        setTimeout(() => {
          if (onSuccess) onSuccess();
        }, 1500);
      }

      return newOrder;
    });
  };

  return (
    <LevelScene
      title="I. Form — Recognition"
      instruction="Arrange the letters to give the word its body."
    >
      <div className="flex flex-col items-center mt-8">
        <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
          <SortableContext items={items} strategy={horizontalListSortingStrategy}>
            <div className="flex gap-3 flex-wrap justify-center" style={{fontSize: '24px'}}>
              {items.map((id, i) => (
                <motion.div
                  key={`${id}-${i}`}
                  animate={{ y: [0, -3, 0] }}
                  transition={{ 
                    repeat: isCorrect ? 0 : Infinity, 
                    duration: 2, 
                    delay: i * 0.1 
                  }}
                >
                  <SortableItem id={id} isCorrect={isCorrect} />
                </motion.div>
              ))}
            </div>
          </SortableContext>
        </DndContext>

        {isCorrect && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-8 text-white text-xl font-display"
          >
            ✓ The word takes shape
          </motion.div>
        )}
      </div>
    </LevelScene>
  );
}

