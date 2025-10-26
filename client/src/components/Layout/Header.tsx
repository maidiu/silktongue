import { Link, useLocation } from 'react-router-dom';
import { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import SearchBar from '../Filters/SearchBar';
import ChangePassword from '../ChangePassword';
import AvatarDisplay from '../Avatar/AvatarDisplay';
import AvatarCustomizer from '../Avatar/AvatarCustomizer';
import type { AvatarConfig } from '../Avatar/types';

interface HeaderProps {
  onSearch?: (query: string) => void;
}

export default function Header({ onSearch }: HeaderProps) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showChangePassword, setShowChangePassword] = useState(false);
  const [showAvatarCustomizer, setShowAvatarCustomizer] = useState(false);
  
  // Determine which section we're on
  const isOnMaps = location.pathname === '/' || location.pathname === '/maps';
  const isOnHome = location.pathname === '/home';

  return (
    <>
    <header className="bg-black/60 backdrop-blur-md sticky top-0 z-50">
      <div className="px-6 py-4">
        {/* Top row: Silk/Health on left, Title in center, Avatar/Menu on right */}
        <div className="flex items-center justify-between mb-4">
          {/* Left: Patreon Link and Silk/Health */}
          <div className="flex flex-col gap-2">
            <a 
              href="https://patreon.com/SimeonWeil" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-yellow-400 hover:text-yellow-300 text-xs font-bold uppercase tracking-wider transition-colors"
            >
              Support on Patreon →
            </a>
            <div className="bg-gray-900 border-2 border-yellow-500 rounded-lg px-6 py-3">
            <div className="text-yellow-400 text-sm font-bold mb-1">💎 Silk Balance</div>
            <div className="text-white text-2xl font-bold">{user?.silkBalance || 0}</div>
            {/* Health below silk */}
            <div className="mt-2 flex items-center gap-2">
              <div className="text-gray-400 text-xs">Health:</div>
              <div className="text-red-500 font-display">
                {'❤️'.repeat(user?.healthPoints || 0)}
              </div>
              <div className="text-gray-500 text-xs">
                ({user?.healthPoints || 0}/{user?.maxHealthPoints || 3})
              </div>
            </div>
            </div>
          </div>

          {/* Center: Laleo Knight Title */}
          <div className="flex-1 flex justify-center">
            <Link to="/" className="group">
              <h1 className="text-6xl font-display font-bold text-white group-hover:text-gray-300 transition-colors tracking-wider" style={{fontSize:'4rem'}}>
                Laleo Knight: Silktongue
              </h1>
            </Link>
          </div>

          {/* Right: Avatar and Menu */}
          <div className="flex items-center space-x-8">
          {/* Avatar and User Menu */}
          <div className="relative flex flex-col items-center">
            {/* Avatar above dropdown */}
            <div className="mb-2">
              <AvatarDisplay 
                config={user?.avatarConfig}
                size={40}
                onClick={() => setShowAvatarCustomizer(true)}
              />
            </div>
            
            {/* User Menu */}
            <button
              onClick={() => setShowUserMenu(!showUserMenu)}
              className="flex items-center space-x-2 px-3 py-2 text-gray-300 hover:text-white hover:bg-gray-800/50 rounded transition-colors"
            >
              <span className="text-sm uppercase tracking-wider font-medium">{user?.username}</span>
              <span className="text-xs">▼</span>
            </button>

              {showUserMenu && (
                <div className="absolute left-0 top-full mt-2 w-56 bg-gray-800 border border-gray-700 rounded-lg shadow-xl z-[100]">
                  <div className="p-4 border-b border-gray-700">
                    <div className="text-white text-sm font-medium">{user?.username}</div>
                    <div className="text-gray-400 text-xs mt-1">Silk: {user?.silkBalance || 0}</div>
                  </div>
                  <div className="py-2">
                    {user?.isAdmin && (
                      <button
                        onClick={async () => {
                          const token = localStorage.getItem('token');
                          await fetch('/api/quiz/admin/clear-cooldowns', {
                            method: 'POST',
                            headers: { 'Authorization': `Bearer ${token}` }
                          });
                          alert('All Beast Mode cooldowns cleared!');
                          setShowUserMenu(false);
                          window.location.reload();
                        }}
                        className="w-full text-left px-4 py-2 text-sm text-orange-400 hover:bg-gray-700 hover:text-orange-300 transition-colors font-semibold"
                      >
                        🔥 Clear All Cooldowns
                      </button>
                    )}
                    
                    {/* Heart Purchase Options */}
                    {user && user.healthPoints < (user.maxHealthPoints || 3) && (
                      <button
                        onClick={async () => {
                          const token = localStorage.getItem('token');
                          const heartsNeeded = (user.maxHealthPoints || 3) - user.healthPoints;
                          const cost = heartsNeeded * 15;
                          
                          if (!confirm(`Restore ${heartsNeeded} heart(s) for ${cost} silk?`)) return;
                          
                          const response = await fetch('/api/quiz/buy-temporary-heart', {
                            method: 'POST',
                            headers: { 
                              'Authorization': `Bearer ${token}`,
                              'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({ amount: heartsNeeded })
                          });
                          
                          const data = await response.json();
                          if (data.success) {
                            alert(`Restored ${data.heartsRestored} heart(s)!`);
                            window.location.reload();
                          } else {
                            alert(data.error || 'Failed to restore hearts');
                          }
                          setShowUserMenu(false);
                        }}
                        className="w-full text-left px-4 py-2 text-sm text-red-400 hover:bg-gray-700 hover:text-red-300 transition-colors"
                      >
                        ❤️ Restore Hearts (15 silk each)
                      </button>
                    )}
                    
                    {user && (user.maxHealthPoints || 3) < 6 && (
                      <button
                        onClick={async () => {
                          const currentMax = user.maxHealthPoints || 3;
                          const costs: Record<number, number> = { 3: 100, 4: 300, 5: 500 };
                          const cost = costs[currentMax];
                          
                          if (!confirm(`Buy permanent heart slot for ${cost} silk? (${currentMax} → ${currentMax + 1} max hearts)`)) return;
                          
                          const token = localStorage.getItem('token');
                          const response = await fetch('/api/quiz/buy-permanent-heart', {
                            method: 'POST',
                            headers: { 'Authorization': `Bearer ${token}` }
                          });
                          
                          const data = await response.json();
                          if (data.success) {
                            alert(`Permanent heart purchased! Max hearts: ${data.newMaxHearts}`);
                            window.location.reload();
                          } else {
                            alert(data.error || 'Failed to buy heart');
                          }
                          setShowUserMenu(false);
                        }}
                        className="w-full text-left px-4 py-2 text-sm text-pink-400 hover:bg-gray-700 hover:text-pink-300 transition-colors font-semibold"
                      >
                        💎 Buy Permanent Heart ({(() => {
                          const costs: Record<number, number> = { 3: 100, 4: 300, 5: 500 };
                          return costs[user.maxHealthPoints || 3];
                        })()} silk)
                      </button>
                    )}
                    
                    <Link
                      to="/maps"
                      onClick={() => setShowUserMenu(false)}
                      className="w-full text-left px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white transition-colors block"
                    >
                      🗺️ Maps
                    </Link>
                    <button
                      onClick={() => {
                        setShowAvatarCustomizer(true);
                        setShowUserMenu(false);
                      }}
                      className="w-full text-left px-4 py-2 text-sm text-purple-400 hover:bg-gray-700 hover:text-purple-300 transition-colors"
                    >
                      🎭 Customize Avatar
                    </button>
                    
                    <button
                      onClick={() => {
                        setShowChangePassword(true);
                        setShowUserMenu(false);
                      }}
                      className="w-full text-left px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white transition-colors"
                    >
                      Change Password
                    </button>
                    <button
                      onClick={() => {
                        logout();
                        setShowUserMenu(false);
                      }}
                      className="w-full text-left px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white transition-colors"
                    >
                      Logout
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Second row: Tower/Asketereion */}
        <div className="flex items-center text-white space-x-3 justify-center mb-3">
          {isOnMaps ? (
            <h2 className="text-3xl font-bold text-white tracking-wider drop-shadow-2xl">
              THE TOWER OF WORDS
            </h2>
          ) : (
            <Link to="/">
              <h2 className="text-3xl font-bold text-white tracking-wider drop-shadow-2xl hover:text-gray-300 transition-colors">
                THE TOWER OF WORDS
              </h2>
            </Link>
          )}
          <span className="text-gray-500 text-2xl">/</span>
          {isOnHome ? (
            <h2 className="text-3xl font-bold text-white tracking-wider drop-shadow-2xl">
              ASKETEREION
            </h2>
          ) : (
            <Link to="/home">
              <h2 className="text-3xl font-bold text-gray-300 tracking-wider drop-shadow-2xl hover:text-white transition-colors">
                ASKETEREION
              </h2>
            </Link>
          )}
        </div>

        {/* Third row: Search Bar */}
        {onSearch && (
          <div className="flex justify-center">
            <div className="w-96">
              <SearchBar onSearch={onSearch} />
            </div>
          </div>
        )}
      </div>
    </header>
    
    {showChangePassword && user && (
      <ChangePassword
        userId={user.id}
        onClose={() => setShowChangePassword(false)}
      />
    )}

    {/* Avatar Customizer Modal */}
    {showAvatarCustomizer && (
      <div className="fixed inset-0 bg-black z-[200] flex items-start justify-center pt-8" style={{backgroundColor: '#000000', top: 0, marginTop: '20px', left:"200px", height: "90vh"}}>
        <div className="bg-gray-800 border border-gray-700 rounded-xl w-[70vw] max-w-3xl max-h-[95vh] overflow-hidden shadow-2xl flex flex-col">
            {/* Header */}
            <div className="flex justify-between items-center p-4 border-b border-gray-700 bg-gray-800">
              <h2 className="text-3xl font-display font-bold text-white">🎭 Customize Your Avatar</h2>
              <button
                onClick={() => setShowAvatarCustomizer(false)}
                className="text-gray-400 hover:text-white text-3xl p-2 hover:bg-gray-700 rounded-lg transition-colors"
              >
                ×
              </button>
            </div>
            
            {/* Content */}
            <div className="flex-1 overflow-y-auto p-4" style={{height:"100%"}}>
              <AvatarCustomizer
                initialConfig={user?.avatarConfig}
                userName={user?.username}
                onSave={async (config: AvatarConfig) => {
                  try {
                    const token = localStorage.getItem('token');
                    const response = await fetch('/api/quiz/save-avatar', {
                      method: 'POST',
                      headers: { 
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                      },
                      body: JSON.stringify({ avatarConfig: config })
                    });
                    
                    const data = await response.json();
                    if (data.success) {
                      alert(`Avatar saved! Cost: ${data.cost} silk`);
                      window.location.reload(); // Refresh to get updated user data
                    } else {
                      alert(data.error || 'Failed to save avatar');
                    }
                  } catch (error) {
                    alert('Failed to save avatar');
                  }
                  setShowAvatarCustomizer(false);
                }}
              />
            </div>
        </div>
      </div>
    )}
    </>
  );
}

