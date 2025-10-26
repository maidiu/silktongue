import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface RoomDetailsPageProps {
  room?: any;
}

const RoomDetailsPage: React.FC<RoomDetailsPageProps> = ({ room: roomFromProps }) => {
  const { roomId } = useParams<{ roomId: string }>();
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  
  const [room, setRoom] = useState<any>(roomFromProps || null);
  const [loading, setLoading] = useState(!roomFromProps);
  const [unlocking, setUnlocking] = useState(false);

  useEffect(() => {
    if (roomFromProps) {
      setRoom(roomFromProps);
      setLoading(false);
    } else if (roomId) {
      fetchRoomDetails();
    }
  }, [roomId, roomFromProps]);

  const fetchRoomDetails = async () => {
    // Get room details from map data
    // For now, we'll use the room data passed via location state
    const stateRoom = location.state?.room;
    if (stateRoom) {
      setRoom(stateRoom);
      setLoading(false);
    }
  };

  const unlockRoom = async () => {
    if (!room || !user) return;

    console.log('🔓 Room data:', room);
    console.log('🔓 map_id:', room.map_id);
    
    // If map_id is missing, use 3 as default (The Tower of Words)
    const mapId = room.map_id || 3;
    
    setUnlocking(true);
    try {
      const response = await fetch(`/api/maps/${mapId}/rooms/${room.id}/unlock`, {
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
      navigate('/maps');
    } catch (error) {
      alert(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Error unlocking room:', error);
    } finally {
      setUnlocking(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Loading...</div>
      </div>
    );
  }

  if (!room) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Room not found</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center p-8">
      <div className="bg-gray-900 border-2 border-blue-500 rounded-lg p-8 max-w-2xl w-full">
        <h2 className="text-3xl font-bold text-white mb-6">
          {room.is_boss_room ? '👹 ' : '🏠 '}
          Room of {room.word}
        </h2>
        
        <p className="text-gray-300 mb-8 text-lg">{room.description}</p>
        
        <div className="grid grid-cols-2 gap-6 mb-8">
          <div className="text-center p-6 bg-gray-800 rounded-lg border-2 border-yellow-500">
            <div className="text-yellow-400 text-xl font-bold mb-2">💎 Cost</div>
            <div className="text-white text-3xl font-bold">{room.silk_cost} Silk</div>
          </div>
          <div className="text-center p-6 bg-gray-800 rounded-lg border-2 border-green-500">
            <div className="text-green-400 text-xl font-bold mb-2">💎 Reward</div>
            <div className="text-white text-3xl font-bold">{room.silk_reward} Silk</div>
          </div>
        </div>

        <div className="bg-blue-900/30 border-2 border-blue-500 rounded-lg p-4 mb-6">
          <div className="text-blue-200 text-center">
            💎 Your Silk Balance: <span className="text-white font-bold text-xl">{user?.silkBalance || 0}</span>
          </div>
        </div>
        
        <div className="flex gap-4">
          {!room.unlocked && !room.is_boss_room && (
            <button
              onClick={unlockRoom}
              disabled={(user?.silkBalance || 0) < room.silk_cost || unlocking}
              className="flex-1 px-8 py-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-lg font-bold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {unlocking ? 'Unlocking...' : `Unlock Room (${room.silk_cost} Silk)`}
            </button>
          )}
          
          <button
            onClick={() => navigate('/maps')}
            className="px-8 py-4 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors text-lg font-bold"
          >
            Back to Map
          </button>
        </div>
      </div>
    </div>
  );
};

export default RoomDetailsPage;

