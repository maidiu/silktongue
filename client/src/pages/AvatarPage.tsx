import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import AvatarCustomizer from '../components/Avatar/AvatarCustomizer';
import AvatarDisplay from '../components/Avatar/AvatarDisplay';
import SilksongAvatar, { defaultAvatarConfigs } from '../components/Avatar/SilksongAvatar';
import type { AvatarConfig } from '../components/Avatar/types';

export default function AvatarPage() {
  const { user } = useAuth();
  const [currentConfig, setCurrentConfig] = useState<AvatarConfig>(user?.avatarConfig || defaultAvatarConfigs.hornet);

  const handleSave = async (config: AvatarConfig) => {
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
        setCurrentConfig(config);
        window.location.reload(); // Refresh to get updated user data
      } else {
        alert(data.error || 'Failed to save avatar');
      }
    } catch (error) {
      alert('Failed to save avatar');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-display font-bold text-white mb-4">
            🎭 Silksong Avatar System
          </h1>
          <p className="text-gray-300 text-lg">
            Customize your character with Silksong-themed parts and effects
          </p>
        </div>

        {/* Current Avatar Display */}
        <div className="bg-gray-800/30 p-8 rounded-lg border border-gray-700 mb-8">
          <h2 className="text-2xl font-display font-bold text-white mb-6 text-center">
            Your Current Avatar
          </h2>
          <div className="flex justify-center">
            <div className="bg-gray-900/50 p-8 rounded-lg border border-gray-600">
              <AvatarDisplay config={currentConfig} size={120} />
            </div>
          </div>
        </div>

        {/* Preset Showcase */}
        <div className="bg-gray-800/30 p-8 rounded-lg border border-gray-700 mb-8">
          <h2 className="text-2xl font-display font-bold text-white mb-6 text-center">
            Preset Characters
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {Object.entries(defaultAvatarConfigs).map(([name, config]) => (
              <div key={name} className="text-center">
                <div className="bg-gray-900/50 p-4 rounded-lg border border-gray-600 mb-3">
                  <SilksongAvatar config={config} size={80} />
                </div>
                <h3 className="text-white font-medium capitalize">{name}</h3>
                <button
                  onClick={() => setCurrentConfig(config)}
                  className="mt-2 px-3 py-1 text-xs uppercase tracking-widest transition-all duration-300
                           bg-blue-600/50 text-blue-300 border border-blue-500 hover:bg-blue-600/70"
                >
                  Use
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Customizer */}
        <AvatarCustomizer
          initialConfig={currentConfig}
          onConfigChange={setCurrentConfig}
          onSave={handleSave}
        />

        {/* Features */}
        <div className="bg-gray-800/30 p-8 rounded-lg border border-gray-700 mt-8">
          <h2 className="text-2xl font-display font-bold text-white mb-6 text-center">
            Avatar Features
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-lg font-semibold text-blue-400 mb-3">🎨 Customization</h3>
              <ul className="text-gray-300 space-y-2">
                <li>• 3 Body Types: Hornet, Knight, Bug</li>
                <li>• 4 Mask Styles: Hornet, Knight, Void, Crystal</li>
                <li>• 4 Wing Types: Silk, Void, Crystal, None</li>
                <li>• 4 Weapon Options: Nail, Needle, Spell, None</li>
                <li>• 8 Silksong-themed Colors</li>
                <li>• 3 Special Effects: Sparkle, Glow, Shadow</li>
              </ul>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-green-400 mb-3">💰 Economy</h3>
              <ul className="text-gray-300 space-y-2">
                <li>• Save avatar for 50 silk</li>
                <li>• Earn silk through quiz completion</li>
                <li>• Beast Mode gives bonus silk</li>
                <li>• Permanent upgrades available</li>
                <li>• Heart restoration system</li>
                <li>• Progressive pricing for hearts</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
