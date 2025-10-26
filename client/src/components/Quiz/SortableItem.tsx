import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

interface SortableItemProps {
  id: string;
  isCorrect?: boolean;
}

export function SortableItem({ id, isCorrect }: SortableItemProps) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id });
  
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      className={`
        w-14 h-14 flex items-center justify-center text-2xl font-display font-bold
        rounded shadow-lg cursor-grab select-none
        transition-all duration-300
        ${isCorrect 
          ? 'bg-white/20 text-white shadow-[0_0_20px_rgba(255,255,255,0.5)]' 
          : 'bg-gray-800/70 text-gray-200 hover:bg-gray-700/70'
        }
      `}
    >
      {id.split('-')[0]}
    </div>
  );
}

