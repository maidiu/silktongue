import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

interface SilksongMapProps {
  floors: Array<{
    id: number;
    floor_number: number;
    name: string;
    rooms: Array<{
      id: number;
      room_number: number;
      name: string;
      word: string;
      word_id: number;
      is_boss_room: boolean;
      unlocked: boolean;
      completed: boolean;
      silk_cost: number;
      silk_reward: number;
      story_completed?: boolean;
      quiz_completed?: boolean;
    }>;
  }>;
  currentFloor: number;
  onRoomClick: (roomId: number) => void;
  onFloorSelect: (floorId: number) => void;
}

const SilksongMap: React.FC<SilksongMapProps> = ({
  floors,
  currentFloor,
  onRoomClick,
  onFloorSelect
}) => {
  const currentFloorData = floors.find(f => f.floor_number === currentFloor);
  const totalRooms = currentFloorData?.rooms.length || 0;
  
  const [isDesktop, setIsDesktop] = useState(false);
  
  useEffect(() => {
    const checkSize = () => setIsDesktop(window.innerWidth >= 1024);
    checkSize();
    window.addEventListener('resize', checkSize);
    return () => window.removeEventListener('resize', checkSize);
  }, []);
  
  // Calculate responsive layout: 2 cols mobile, 3 cols desktop
  const cols = isDesktop ? 3 : 2;
  const rows = Math.ceil(totalRooms / cols);
  
  // Card dimensions (bigger on mobile for better touch targets)
  const cardWidth = isDesktop ? 160 : 180;
  const cardHeight = isDesktop ? 140 : 160;
  const gapX = isDesktop ? 60 : 40;  // Gap between cards
  const gapY = isDesktop ? 30 : 30;
  
  // Calculate spacing (center to center)
  const spacingX = cardWidth + gapX;
  const spacingY = cardHeight + gapY;
  
  // Calculate SVG dimensions - ensure all cards fit
  const totalWidth = cols * cardWidth + (cols - 1) * gapX + 80; // +80 for side padding
  const totalHeight = rows * cardHeight + (rows - 1) * gapY + 100; // Extra height to prevent clipping
  
  return (
    <div className="relative w-full bg-stone-900" style={{ pointerEvents: 'auto' }}>
      {/* Floor navigation */}
      <div className="bg-stone-900/95 backdrop-blur-sm border-b border-stone-700" style={{ pointerEvents: 'auto'}}>
        <div className="flex justify-center gap-4 p-4">
          {floors.map((floor) => (
            <motion.button
              key={floor.id}
              onClick={() => onFloorSelect(floor.id)}
              className={`px-6 py-2 rounded-lg border-2 font-bold uppercase text-sm ${
                currentFloor === floor.floor_number
                  ? 'border-cyan-400 bg-cyan-900/20 text-cyan-200'
                  : 'border-stone-700 bg-stone-800 text-stone-300 hover:border-stone-600'
              }`}
              
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              Floor {floor.floor_number}
            </motion.button>
          ))}
        </div>
      </div>

      {/* Map container - scrollable area */}
      <div className="overflow-y-auto" style={{ padding: '8px', pointerEvents: 'auto', width: '100%', maxHeight: '80vh', display: 'flex', justifyContent: 'center', alignItems: 'flex-start'}}>
        <svg 
          width={totalWidth} 
          height={totalHeight}
          viewBox={`0 0 ${totalWidth} ${totalHeight}`}
          style={{ display: 'block' }}
        >
          {/* Grid pattern background */}
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#3a3a3a" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width={totalWidth} height={totalHeight} fill="#2a2a2a" />
          <rect width={totalWidth} height={totalHeight} fill="url(#grid)" />

          {/* Simple grid of room cards */}
          {currentFloorData?.rooms.map((room, index) => {
            const row = Math.floor(index / cols);
            const col = index % cols;
            
            // Center the grid within the padded area
            const gridWidth = cols * cardWidth + (cols - 1) * gapX;
            const startX = (totalWidth - gridWidth) / 2;
            const startY = 50;
            
            const x = startX + col * spacingX;
            const y = startY + row * spacingY;
            
            const bgColor = room.is_boss_room 
              ? '#7f1d1d' 
              : room.completed 
              ? '#064e3b' 
              : room.unlocked 
              ? '#1e3a5f' 
              : '#1f1f1f';
            
            const borderColor = room.is_boss_room 
              ? '#991b1b' 
              : room.completed 
              ? '#065f46' 
              : room.unlocked 
              ? '#1e40af' 
              : '#404040';

            return (
              <g key={room.id}>
                {/* Room background */}
                <motion.rect
                  x={x}
                  y={y}
                  width={cardWidth}
                  height={cardHeight}
                  fill={bgColor}
                  stroke={borderColor}
                  strokeWidth="2"
                  rx="4"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: room.unlocked ? 1 : 0.3 }}
                  transition={{ duration: 0.5, delay: index * 0.1 }}
                  whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
                  style={{ pointerEvents: 'none', transformOrigin: `${x + cardWidth/2}px ${y + cardHeight/2}px` }}
                />
                
                {/* Clickable overlay for ALL rooms (locked and unlocked, but not boss rooms with buttons) */}
                {!room.is_boss_room && (
                  <rect
                    x={x}
                    y={y}
                    width={cardWidth}
                    height={cardHeight - 30}
                    fill="transparent"
                    style={{ cursor: 'pointer', pointerEvents: 'auto' }}
                    onClick={(e) => {
                      e.stopPropagation();
                      onRoomClick(room.id);
                    }}
                  />
                )}
                
                {/* Room label */}
                <text
                  x={x + cardWidth/2}
                  y={y + 28}
                  textAnchor="middle"
                  className="select-none"
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    fill: room.unlocked ? '#ffffff' : '#666666',
                    pointerEvents: 'none'
                  }}
                >
                  {room.word}
                </text>

                {/* Status icon */}
                <text
                  x={x + cardWidth/2}
                  y={y + 68}
                  textAnchor="middle"
                  fontSize="32"
                  className="select-none"
                  style={{ pointerEvents: 'none' }}
                >
                  {room.is_boss_room ? '👹' : room.completed ? '✓' : room.unlocked ? '🔓' : '🔒'}
                </text>

                {/* Action buttons - only show if room is unlocked and NOT a boss room */}
                {room.unlocked && !room.is_boss_room && (
                  <g>
                    {/* Story button (📚) - always visible when unlocked */}
                    <g style={{ pointerEvents: 'auto' }}>
                      <circle cx={x + 35} cy={y + 96} r="10" fill="#7c2d12" stroke="#9a3412" strokeWidth="1.5" 
                        className="cursor-pointer"
                        onClick={(e) => {
                          e.stopPropagation();
                          window.location.href = `/word-exploration/${room.word_id}`;
                        }}
                      />
                      <text x={x + 35} y={y + 102} textAnchor="middle" fontSize="12" style={{ pointerEvents: 'none' }}>📚</text>
                    </g>
                    
                    {/* Battle button (⚔️) - only show after story is completed (or if room is completed as fallback) */}
                    {(room.story_completed || room.completed) && (
                      <g style={{ pointerEvents: 'auto' }}>
                        <circle cx={x + cardWidth/2} cy={y + 96} r="10" fill="#1e3a5f" stroke="#2563eb" strokeWidth="1.5"
                          className="cursor-pointer"
                          onClick={(e) => {
                            e.stopPropagation();
                            window.location.href = `/quiz/${room.word_id}`;
                          }}
                        />
                        <text x={x + cardWidth/2} y={y + 102} textAnchor="middle" fontSize="12" style={{ pointerEvents: 'none' }}>⚔️</text>
                      </g>
                    )}
                    
                    {/* Beast Mode button (👾) - only show after battle/quiz is completed */}
                    {room.completed && room.word_id && (
                      <g style={{ pointerEvents: 'auto' }}>
                        <circle cx={x + cardWidth - 35} cy={y + 96} r="10" fill="#581c87" stroke="#7c3aed" strokeWidth="1.5"
                          className="cursor-pointer"
                          onClick={(e) => {
                            e.stopPropagation();
                            // Navigate to level 6 quiz
                            if (room.word_id) {
                              window.location.href = `/quiz/${room.word_id}?level=6`;
                            }
                          }}
                        />
                        <text x={x + cardWidth - 35} y={y + 102} textAnchor="middle" fontSize="12" style={{ pointerEvents: 'none' }}>👾</text>
                      </g>
                    )}
                  </g>
                )}
                
                {/* Boss room - make the whole card clickable */}
                {room.unlocked && room.is_boss_room && room.completed && (
                  <motion.rect
                    x={x}
                    y={y}
                    width={cardWidth}
                    height={cardHeight}
                    fill="transparent"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    style={{ pointerEvents: 'auto', cursor: 'pointer' }}
                    onClick={(e) => {
                      e.stopPropagation();
                      onRoomClick(room.id);
                    }}
                  />
                )}
              </g>
            );
          })}
        </svg>
      </div>
    </div>
  );
};

export default SilksongMap;
