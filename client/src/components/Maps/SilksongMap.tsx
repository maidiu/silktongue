import React from 'react';
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
  console.log('SilksongMap render:', { 
    floorsLength: floors.length, 
    currentFloor, 
    rooms: floors[currentFloor - 1]?.rooms,
    onRoomClick: typeof onRoomClick
  });
  
  return (
    <div className="relative w-full h-full bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900 overflow-hidden" style={{ pointerEvents: 'auto' }}>
      {/* Enhanced atmospheric effects */}
      <div className="absolute inset-0" style={{ pointerEvents: 'none' }}>
        {/* Floating particles */}
        <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-cyan-400/60 rounded-full animate-pulse"></div>
        <div className="absolute top-3/4 right-1/4 w-1 h-1 bg-purple-400/60 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 w-3 h-3 bg-pink-400/40 rounded-full animate-pulse delay-2000"></div>
        
        {/* Glowing orbs */}
        <div className="absolute top-20 left-20 w-64 h-64 bg-cyan-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-20 right-20 w-48 h-48 bg-purple-500/10 rounded-full blur-2xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 w-32 h-32 bg-pink-500/15 rounded-full blur-xl animate-pulse delay-2000 transform -translate-x-16 -translate-y-16"></div>
      </div>
      
      {/* Map container */}
      <div className="relative z-10 p-8 h-full flex flex-col">
        
        {/* Enhanced floors navigation */}
        <motion.div 
          className="flex justify-center mb-8 space-x-4"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
        >
          {floors.map((floor) => (
            <motion.button
              key={floor.id}
              onClick={() => onFloorSelect(floor.id)}
              className={`px-6 py-3 rounded-xl border-2 transition-all duration-300 font-bold ${
                currentFloor === floor.floor_number
                  ? 'border-cyan-400 bg-gradient-to-r from-cyan-500/30 to-purple-500/30 text-cyan-200 shadow-lg shadow-cyan-500/25'
                  : 'border-purple-600/50 bg-purple-900/30 text-purple-200 hover:border-purple-400 hover:bg-purple-800/40'
              }`}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              Floor {floor.floor_number}
            </motion.button>
          ))}
          
          {/* Floor 2 locked tab */}
          <motion.div
            className="px-6 py-3 rounded-xl border-2 border-gray-600/50 bg-gray-900/30 text-gray-400 cursor-not-allowed flex items-center gap-2"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
          >
            <span className="font-bold">Floor 2</span>
            <span className="text-lg">🔒</span>
          </motion.div>
        </motion.div>
        
        {/* Enhanced current floor map */}
        <div className="flex-1 flex justify-center items-center">
          <motion.div 
            className="relative"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, delay: 0.4 }}
          >
            {/* Enhanced floor background */}
            <div className="w-[600px] h-[600px] bg-gradient-to-br from-gray-800/90 via-gray-900/90 to-black/90 rounded-3xl border-4 border-gradient-to-r from-cyan-500/50 to-purple-500/50 shadow-2xl backdrop-blur-sm">
              {/* Room nodes */}
              <div className="absolute inset-8">
                {floors[currentFloor - 1]?.rooms.map((room, index) => {
                  const totalRooms = floors[currentFloor - 1]?.rooms.length || 0;
                  const angle = (index * 2 * Math.PI) / totalRooms;
                  const radius = 180;
                  const centerX = 280;
                  const centerY = 280;
                  
                  const x = centerX + radius * Math.cos(angle);
                  const y = centerY + radius * Math.sin(angle);
                  
                  return (
                    <motion.div 
                      key={room.id} 
                      className="absolute"
                      initial={{ opacity: 0, scale: 0 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ duration: 0.6, delay: 0.6 + index * 0.1 }}
                    >
                      {/* Enhanced connection line to center */}
                      <div
                        className="absolute bg-gradient-to-r from-cyan-400/60 to-purple-400/60 shadow-lg"
                        style={{
                          left: centerX,
                          top: centerY,
                          width: Math.sqrt((x - centerX) ** 2 + (y - centerY) ** 2),
                          height: 3,
                          transform: `rotate(${(angle * 180) / Math.PI}deg)`,
                          transformOrigin: 'left center',
                          zIndex: 1
                        }}
                      ></div>
                      
                      {/* Room container with word and status info */}
                      <motion.div
                        className="absolute flex flex-col items-center gap-2"
                        style={{ left: x - 80, top: y - 40, zIndex: 10 }}
                      >
                        {/* Word label */}
                        <motion.div
                          className="text-3xl font-bold text-white bg-gradient-to-r from-gray-900/90 to-black/90 px-6 py-4 rounded-xl border-2 border-gray-600/50 shadow-lg backdrop-blur-sm cursor-pointer transition-all duration-300 hover:bg-gradient-to-r hover:from-gray-800/90 hover:to-gray-900/90 hover:border-blue-400/50"
                          onClick={(e) => {
                            e.stopPropagation();
                            e.preventDefault();
                            console.log('Word clicked for room:', room.id, room.word);
                            onRoomClick(room.id);
                          }}
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          {room.word}
                        </motion.div>
                        
                        {/* Lock/unlock status */}
                        <motion.div
                          className={`w-20 h-20 rounded-full border-2 cursor-pointer transition-all duration-300 flex items-center justify-center ${
                            room.is_boss_room
                              ? 'bg-gradient-to-br from-red-600 to-red-800 border-red-400 shadow-2xl shadow-red-500/50'
                              : room.completed
                              ? 'bg-gradient-to-br from-green-600 to-green-800 border-green-400 shadow-2xl shadow-green-500/50'
                              : room.unlocked
                              ? 'bg-gradient-to-br from-blue-600 to-blue-800 border-blue-400 shadow-2xl shadow-blue-500/50'
                              : 'bg-gradient-to-br from-gray-600 to-gray-800 border-gray-400'
                          }`}
                          onClick={(e) => {
                            e.stopPropagation();
                            e.preventDefault();
                            console.log('🔒 Icon clicked for room:', room.id, room.word, 'unlocked:', room.unlocked);
                            onRoomClick(room.id);
                          }}
                          whileHover={{ scale: 1.15, rotate: 5 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          {room.is_boss_room ? (
                            <span className="text-red-200 text-4xl font-bold">👹</span>
                          ) : room.completed ? (
                            <span className="text-green-200 text-4xl font-bold">✓</span>
                          ) : room.unlocked ? (
                            <span className="text-blue-200 text-4xl">🔓</span>
                          ) : (
                            <span className="text-gray-300 text-4xl">🔒</span>
                          )}
                        </motion.div>
                        
                        {/* Progress icons row - only show if unlocked */}
                        {room.unlocked && !room.is_boss_room && (
                          <div className="flex gap-2 mt-2">
                            {/* Story/Books icon - always available if unlocked */}
                            <motion.button
                              className="w-10 h-10 bg-yellow-600/80 rounded-full border-2 border-yellow-400 flex items-center justify-center cursor-pointer hover:bg-yellow-500/90 transition-all"
                              onClick={(e) => {
                                e.stopPropagation();
                                e.preventDefault();
                                console.log('📚 Story clicked for word:', room.word_id);
                                // Navigate to word exploration page
                                window.location.href = `/word-exploration/${room.word_id}`;
                              }}
                              whileHover={{ scale: 1.15, rotate: 5 }}
                              whileTap={{ scale: 0.95 }}
                              title="Story Study"
                            >
                              <span className="text-xl">📚</span>
                            </motion.button>
                            
                            {/* Battle/Swords icon - available if unlocked */}
                            <motion.button
                              className="w-10 h-10 bg-blue-600/80 rounded-full border-2 border-blue-400 flex items-center justify-center cursor-pointer hover:bg-blue-500/90 transition-all"
                              onClick={(e) => {
                                e.stopPropagation();
                                e.preventDefault();
                                console.log('⚔️ Battle clicked for word:', room.word_id);
                                // Navigate to quiz page
                                window.location.href = `/quiz/${room.word_id}`;
                              }}
                              whileHover={{ scale: 1.15, rotate: -5 }}
                              whileTap={{ scale: 0.95 }}
                              title="Battle (Levels 1-5)"
                            >
                              <span className="text-xl">⚔️</span>
                            </motion.button>
                            
                            {/* Beast Mode icon - only show if completed */}
                            {room.completed && (
                              <motion.button
                                className="w-10 h-10 bg-purple-600/80 rounded-full border-2 border-purple-400 flex items-center justify-center cursor-pointer hover:bg-purple-500/90 transition-all"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  e.preventDefault();
                                  console.log('👾 Beast Mode clicked for word:', room.word_id);
                                  // Navigate directly to Beast Mode quiz
                                  window.location.href = `/quiz/${room.word_id}`;
                                }}
                                whileHover={{ scale: 1.15, rotate: 5 }}
                                whileTap={{ scale: 0.95 }}
                                title="Beast Mode"
                              >
                                <span className="text-xl">👾</span>
                              </motion.button>
                            )}
                          </div>
                        )}
                      </motion.div>
                    </motion.div>
                  );
                })}
                
                {/* Enhanced center hub */}
                <motion.div 
                  className="absolute w-32 h-32 bg-gradient-to-br from-cyan-500 via-purple-500 to-pink-500 rounded-full border-4 border-white shadow-2xl transform -translate-x-16 -translate-y-16"
                  style={{ left: 280, top: 280 }}
                  initial={{ opacity: 0, scale: 0 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 1, delay: 0.8 }}
                  whileHover={{ scale: 1.1, rotate: 360 }}
                >
                  <div className="flex items-center justify-center h-full">
                    <span className="text-white text-3xl font-bold drop-shadow-lg">★</span>
                  </div>
                </motion.div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
};

export default SilksongMap;