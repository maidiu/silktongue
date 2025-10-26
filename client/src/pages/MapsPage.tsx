import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import Layout from '../components/Layout/Layout';
import SilksongMap from '../components/Maps/SilksongMap';
import WordExplorationModal from '../components/Maps/WordExplorationModal';

interface Map {
  id: number;
  name: string;
  description: string;
  total_floors: number;
  floors: Floor[];
  progress: UserProgress;
}

interface Floor {
  id: number;
  floor_number: number;
  name: string;
  description: string;
  unlock_requirement: string;
  silk_reward: number;
  rooms: Room[];
}

interface Room {
  id: number;
  room_number: number;
  name: string;
  description: string;
  silk_cost: number;
  silk_reward: number;
  is_boss_room: boolean;
  word: string;
  word_id: number;
  unlocked: boolean;
  completed: boolean;
}

interface UserProgress {
  current_floor: number;
  current_room: number;
  floors_completed: number;
  total_silk_spent: number;
  total_silk_earned: number;
}

interface BossScenario {
  id: number;
  scenario_text: string;
  difficulty_level: number;
}

interface BossAttempt {
  attemptId: number;
  scenarios: BossScenario[];
  totalScenarios: number;
}

const MapsPage: React.FC = () => {
  const { user, refreshUser } = useAuth();
  const navigate = useNavigate();
  const [, setMaps] = useState<Map[]>([]);
  const [selectedMap, setSelectedMap] = useState<Map | null>(null);
  const [selectedFloor, setSelectedFloor] = useState<Floor | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const [bossAttempt, setBossAttempt] = useState<BossAttempt | null>(null);
  const [bossResponses, setBossResponses] = useState<{[key: number]: string}>({});
  const [showBossChallenge, setShowBossChallenge] = useState(false);
  const [showRoomDetails, setShowRoomDetails] = useState(false);
  const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
  const [showWordExploration, setShowWordExploration] = useState(false);
  const [wordData, setWordData] = useState<any>(null);

  useEffect(() => {
    fetchMaps();
    refreshUser(); // Refresh user data to get updated silk balance
  }, []);

  const fetchMaps = async () => {
    try {
      const response = await fetch('/api/maps', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to fetch maps');
      }
      
      const mapsData = await response.json();
      setMaps(mapsData);
      
      if (mapsData.length > 0) {
        fetchMapDetails(mapsData[0].id);
      }
    } catch (error) {
      setError('Failed to load maps');
      console.error('Error fetching maps:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchMapDetails = async (mapId: number) => {
    try {
      const response = await fetch(`/api/maps/${mapId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to fetch map details');
      }
      
      const mapData = await response.json();
      
      setSelectedMap(mapData);
      
      if (mapData.floors.length > 0) {
        setSelectedFloor(mapData.floors[0]);
      }
    } catch (error) {
      setError('Failed to load map details');
      console.error('Error fetching map details:', error);
    }
  };

  const unlockRoom = async (roomId: number) => {
    if (!selectedMap) return;
    
    try {
      const response = await fetch(`/api/maps/${selectedMap.id}/rooms/${roomId}/unlock`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to unlock room');
      }
      
      const result = await response.json();
      alert(result.message);
      
      // Refresh map details
      fetchMapDetails(selectedMap.id);
    } catch (error) {
      alert(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Error unlocking room:', error);
    }
  };

  const _completeRoom = async (roomId: number) => {
    if (!selectedMap) return;
    
    try {
      const response = await fetch(`/api/maps/${selectedMap.id}/rooms/${roomId}/complete`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to complete room');
      }
      
      const result = await response.json();
      alert(result.message);
      
      // Refresh map details
      fetchMapDetails(selectedMap.id);
    } catch (error) {
      alert(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Error completing room:', error);
    }
  };

  const startBossChallenge = async (floorId: number) => {
    if (!selectedMap) return;
    
    try {
      const response = await fetch(`/api/maps/${selectedMap.id}/floors/${floorId}/boss/start`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to start boss challenge');
      }
      
      const attempt = await response.json();
      setBossAttempt(attempt);
      setBossResponses({});
      setShowBossChallenge(true);
    } catch (error) {
      alert(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Error starting boss challenge:', error);
    }
  };

  const completeBossChallenge = async () => {
    if (!selectedMap || !selectedFloor || !bossAttempt) return;
    
    const responses = Object.entries(bossResponses).map(([scenarioId, word]) => ({
      scenarioId: parseInt(scenarioId),
      word: word.trim()
    }));
    
    try {
      const response = await fetch(`/api/maps/${selectedMap.id}/floors/${selectedFloor.id}/boss/complete`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          attemptId: bossAttempt.attemptId,
          responses
        })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to complete boss challenge');
      }
      
      const result = await response.json();
      alert(result.message);
      
      // Close boss challenge and refresh map details
      setShowBossChallenge(false);
      setBossAttempt(null);
      setBossResponses({});
      fetchMapDetails(selectedMap.id);
    } catch (error) {
      alert(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Error completing boss challenge:', error);
    }
  };

  const handleRoomClick = async (roomId: number) => {
    console.log('🚀 CLICK DETECTED! handleRoomClick called with roomId:', roomId);
    console.log('selectedFloor:', selectedFloor);
    
    if (!selectedFloor) {
      console.log('No selected floor');
      return;
    }
    
    const room = selectedFloor.rooms.find(r => r.id === roomId);
    console.log('Found room:', room);
    console.log('Room unlocked status:', room?.unlocked);
    
    if (!room) {
      console.log('Room not found');
      return;
    }
    
    setSelectedRoom(room);
    
    // If room is unlocked, navigate to word exploration (learning) page
    if (room.unlocked) {
      console.log('✅ Room unlocked, navigating to word exploration page');
      navigate(`/word-exploration/${room.word_id}`);
    } else {
      // If locked, navigate to room details page
      console.log('🔒 Navigating to room details for locked room');
      navigate(`/room-details/${room.id}`, { state: { room } });
    }
  };

  const handleFloorSelect = (floorId: number) => {
    if (!selectedMap) return;
    
    const floor = selectedMap.floors.find(f => f.id === floorId);
    if (floor) {
      setSelectedFloor(floor);
    }
  };

  const goToWordDetail = () => {
    if (selectedRoom) {
      navigate(`/word/${selectedRoom.word_id}`);
      setShowRoomDetails(false);
    }
  };

  const goToQuiz = () => {
    if (selectedRoom) {
      navigate(`/quiz/${selectedRoom.word_id}`);
      setShowRoomDetails(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Loading Maps...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-red-400 text-xl">{error}</div>
      </div>
    );
  }

  return (
    <Layout>
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 relative">
      {/* Silk Balance Display */}
      
      
      {selectedMap && selectedFloor && (
        <>
          <div className="h-screen" style={{ pointerEvents: 'none' }}>
            <SilksongMap
              floors={selectedMap.floors}
              currentFloor={selectedFloor.floor_number}
              onRoomClick={handleRoomClick}
              onFloorSelect={handleFloorSelect}
            />
          </div>
          
          {/* Floor Title and Description */}
          <div className="absolute bottom-10 sm:bottom-20 left-1/2 transform -translate-x-1/2 flex flex-col items-center justify-center pointer-events-none w-full">
            <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-2 sm:mb-3 text-center px-4">{selectedFloor.name}</h2>
            <p className="text-white text-sm sm:text-base md:text-lg max-w-3xl text-center px-4 sm:px-8">
              Untold chambers of ancient knowledge await your exploration. Unlock rooms with Silk to access Lexical Battles and Beast Mode challenges.
            </p>
          </div>
        </>
      )}

        {/* Room Details Modal */}
        {showRoomDetails && selectedRoom && (
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-[100] p-2 sm:p-4" style={{ pointerEvents: 'auto' }}>
            <div className="bg-gray-900 border-2 border-blue-500 rounded-lg p-4 sm:p-6 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <h2 className="text-xl sm:text-2xl font-bold text-white mb-3 sm:mb-4">
                {selectedRoom.is_boss_room ? '👹 ' : '🏠 '}
                Room of {selectedRoom.word}
              </h2>
              
              <p className="text-gray-300 mb-4 sm:mb-6 text-sm sm:text-base">{selectedRoom.description}</p>
              
              <div className="grid grid-cols-2 gap-3 sm:gap-4 mb-4 sm:mb-6">
                <div className="text-center p-4 bg-gray-800 rounded-lg">
                  <div className="text-yellow-400 text-lg font-bold">💎 Cost</div>
                  <div className="text-white text-xl">{selectedRoom.silk_cost} Silk</div>
                </div>
                <div className="text-center p-4 bg-gray-800 rounded-lg">
                  <div className="text-green-400 text-lg font-bold">💎 Reward</div>
                  <div className="text-white text-xl">{selectedRoom.silk_reward} Silk</div>
                </div>
              </div>
              
              <div className="flex flex-col sm:flex-row gap-3 sm:gap-4">
                {!selectedRoom.unlocked && !selectedRoom.is_boss_room && (
                  <button
                    onClick={() => {
                      unlockRoom(selectedRoom.id);
                      setShowRoomDetails(false);
                    }}
                    className="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors text-sm sm:text-base"
                    disabled={(user?.silkBalance || 0) < selectedRoom.silk_cost}
                  >
                    Unlock Room ({selectedRoom.silk_cost} Silk)
                  </button>
                )}
                
                {selectedRoom.unlocked && (
                  <>
                    <button
                      onClick={goToWordDetail}
                      className="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 bg-purple-600 text-white rounded hover:bg-purple-700 transition-colors text-sm sm:text-base"
                    >
                      📖 View Word Details
                    </button>
                    <button
                      onClick={goToQuiz}
                      className="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 bg-green-600 text-white rounded hover:bg-green-700 transition-colors text-sm sm:text-base"
                    >
                      🎯 Start Quiz
                    </button>
                  </>
                )}
                
                {selectedRoom.is_boss_room && selectedFloor && (
                  <button
                    onClick={() => {
                      startBossChallenge(selectedFloor.id);
                      setShowRoomDetails(false);
                    }}
                    className="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 bg-red-600 text-white rounded hover:bg-red-700 transition-colors text-sm sm:text-base"
                  >
                    👹 Challenge Floor Guardian
                  </button>
                )}
              </div>
              
              <button
                onClick={() => setShowRoomDetails(false)}
                className="w-full mt-4 px-6 py-3 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        )}


        {/* Boss Challenge Modal */}
        {showBossChallenge && bossAttempt && (
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50">
            <div className="bg-gray-900 border-2 border-red-500 rounded-lg p-6 max-w-4xl max-h-[90vh] overflow-y-auto">
              <h2 className="text-2xl font-bold text-white mb-4">
                👹 Floor Boss Challenge
              </h2>
              <p className="text-gray-300 mb-6">
                The Floor Guardian presents you with scenarios. You must type the correct word for each scenario.
                You must get ALL of them correct to clear the floor!
              </p>
              
              <div className="space-y-4">
                {bossAttempt.scenarios.map((scenario, index) => (
                  <div key={scenario.id} className="p-4 bg-gray-800 rounded-lg">
                    <h3 className="text-lg font-bold text-white mb-2">
                      Scenario {index + 1}:
                    </h3>
                    <p className="text-gray-300 mb-3">{scenario.scenario_text}</p>
                    <input
                      type="text"
                      value={bossResponses[scenario.id] || ''}
                      onChange={(e) => setBossResponses(prev => ({
                        ...prev,
                        [scenario.id]: e.target.value
                      }))}
                      placeholder="Type the word here..."
                      className="w-full p-3 bg-gray-700 text-white rounded border border-gray-600 focus:border-blue-500 focus:outline-none"
                    />
                  </div>
                ))}
              </div>
              
              <div className="flex gap-4 mt-6">
                <button
                  onClick={completeBossChallenge}
                  className="px-6 py-3 bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
                >
                  Submit Challenge
                </button>
                <button
                  onClick={() => {
                    setShowBossChallenge(false);
                    setBossAttempt(null);
                    setBossResponses({});
                  }}
                  className="px-6 py-3 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}
    </div>
    {/* Word Exploration Modal - Outside main container */}
    {showWordExploration && wordData && selectedRoom && (
      <WordExplorationModal
        word={wordData.word}
        wordId={wordData.id}
        definitions={wordData.definitions || []}
        synonyms={wordData.synonyms || []}
        antonyms={wordData.antonyms || []}
        etymology={wordData.etymology}
        story={wordData.story || []}
        story_intro={wordData.story_intro}
        onClose={() => {
          setShowWordExploration(false);
          setWordData(null);
        }}
        onComplete={() => {
          setShowWordExploration(false);
          setWordData(null);
          if (selectedRoom) {
            navigate(`/quiz/${selectedRoom.word_id}`);
          }
        }}
      />
    )}
    </Layout>
  );
};

export default MapsPage;
