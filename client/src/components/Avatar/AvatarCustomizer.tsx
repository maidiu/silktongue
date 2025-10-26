import { useState } from 'react';
import SilksongAvatar, { defaultAvatarConfigs } from './SilksongAvatar';
import type { AvatarConfig } from './types';

interface AvatarCustomizerProps {
  initialConfig?: AvatarConfig;
  onConfigChange?: (config: AvatarConfig) => void;
  onSave?: (config: AvatarConfig) => void;
  userName?: string;
}

export default function AvatarCustomizer({ 
  initialConfig = defaultAvatarConfigs.hornet, 
  onConfigChange,
  onSave,
  userName
}: AvatarCustomizerProps) {
  const [config, setConfig] = useState<AvatarConfig>(initialConfig);

  const updateConfig = (updates: Partial<AvatarConfig>) => {
    const newConfig = { ...config, ...updates };
    setConfig(newConfig);
    onConfigChange?.(newConfig);
  };

  const colorOptions = [
    { name: 'Silksong Red', value: '#ff6b6b' },
    { name: 'Silksong Blue', value: '#4ecdc4' },
    { name: 'Silksong Purple', value: '#7c3aed' },
    { name: 'Silksong Green', value: '#00d4aa' },
    { name: 'Silksong Orange', value: '#ff8c42' },
    { name: 'Silksong Pink', value: '#ff69b4' },
    { name: 'Void Black', value: '#0d1117' },
    { name: 'Crystal White', value: '#ffffff' }
  ];

  return (
    <div className="bg-gray-800/30 p-4 rounded-lg border border-gray-700">
      <h3 className="text-lg font-display font-bold text-white mb-4 uppercase tracking-wider">
        🎭 {userName || 'Customize Your Avatar'}
      </h3>
      
      <div className="grid grid-cols-2 gap-6 max-h-[50vh]">
        {/* Avatar Preview */}
        <div className="flex flex-col items-center">
          <div className="bg-gray-900/50 p-4 rounded-lg border border-gray-600 mb-4">
            <SilksongAvatar config={config} size={200} />
          </div>
          
          {/* Quick Presets */}
          <div className="grid grid-cols-2 gap-2 w-full">
            {Object.entries(defaultAvatarConfigs).map(([name, preset]) => (
              <button
                key={name}
                onClick={() => updateConfig(preset)}
                className="px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300
                         bg-gray-700/50 text-gray-300 border border-gray-600 hover:bg-gray-600/50 hover:text-white"
              >
                {name}
              </button>
            ))}
          </div>
        </div>

        {/* Customization Options */}
        <div className="space-y-3 overflow-y-auto max-h-[50vh]">
          {/* Body Type */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Body Type</label>
            <div className="grid grid-cols-3 gap-2">
              {(['hornet', 'knight', 'bug'] as const).map((body) => (
                <button
                  key={body}
                  onClick={() => updateConfig({ body })}
                  className={`px-4 py-3 text-sm font-bold uppercase tracking-widest transition-all duration-300 rounded-lg ${
                    config.body === body
                      ? 'bg-blue-600/70 text-blue-200 border-2 border-blue-400 shadow-lg shadow-blue-500/25'
                      : 'bg-gray-700/70 text-gray-200 border-2 border-gray-500 hover:bg-gray-600/70 hover:border-gray-400'
                  }`}
                >
                  {body}
                </button>
              ))}
            </div>
          </div>

          {/* Mask */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Mask</label>
            <div className="grid grid-cols-2 gap-2">
              {(['hornet', 'knight', 'void', 'crystal'] as const).map((mask) => (
                <button
                  key={mask}
                  onClick={() => updateConfig({ mask })}
                  className={`px-4 py-3 text-sm font-bold uppercase tracking-widest transition-all duration-300 rounded-lg ${
                    config.mask === mask
                      ? 'bg-green-600/70 text-green-200 border-2 border-green-400 shadow-lg shadow-green-500/25'
                      : 'bg-gray-700/70 text-gray-200 border-2 border-gray-500 hover:bg-gray-600/70 hover:border-gray-400'
                  }`}
                >
                  {mask}
                </button>
              ))}
            </div>
          </div>

          {/* Wings */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Wings</label>
            <div className="grid grid-cols-2 gap-2">
              {(['none', 'silk', 'void', 'crystal'] as const).map((wings) => (
                <button
                  key={wings}
                  onClick={() => updateConfig({ wings })}
                  className={`px-4 py-3 text-sm font-bold uppercase tracking-widest transition-all duration-300 rounded-lg ${
                    config.wings === wings
                      ? 'bg-purple-600/70 text-purple-200 border-2 border-purple-400 shadow-lg shadow-purple-500/25'
                      : 'bg-gray-700/70 text-gray-200 border-2 border-gray-500 hover:bg-gray-600/70 hover:border-gray-400'
                  }`}
                >
                  {wings}
                </button>
              ))}
            </div>
          </div>

          {/* Weapon */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Weapon</label>
            <div className="grid grid-cols-2 gap-2">
              {(['none', 'nail', 'needle', 'spell'] as const).map((weapon) => (
                <button
                  key={weapon}
                  onClick={() => updateConfig({ weapon })}
                  className={`px-4 py-3 text-sm font-bold uppercase tracking-widest transition-all duration-300 rounded-lg ${
                    config.weapon === weapon
                      ? 'bg-orange-600/70 text-orange-200 border-2 border-orange-400 shadow-lg shadow-orange-500/25'
                      : 'bg-gray-700/70 text-gray-200 border-2 border-gray-500 hover:bg-gray-600/70 hover:border-gray-400'
                  }`}
                >
                  {weapon}
                </button>
              ))}
            </div>
          </div>

          {/* Colors */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Primary Color</label>
            <div className="grid grid-cols-4 gap-4">
              {colorOptions.map((color) => (
                <button
                  key={color.value}
                  onClick={() => updateConfig({ primaryColor: color.value })}
                  className={`w-20 h-20 rounded-lg border-4 transition-all duration-300 hover:scale-110 ${
                    config.primaryColor === color.value ? 'border-white shadow-lg shadow-white/50' : 'border-gray-600 hover:border-gray-400'
                  }`}
                  style={{ backgroundColor: color.value }}
                  title={color.name}
                />
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Accent Color</label>
            <div className="grid grid-cols-4 gap-4">
              {colorOptions.map((color) => (
                <button
                  key={color.value}
                  onClick={() => updateConfig({ accentColor: color.value })}
                  className={`w-20 h-20 rounded-lg border-4 transition-all duration-300 hover:scale-110 ${
                    config.accentColor === color.value ? 'border-white shadow-lg shadow-white/50' : 'border-gray-600 hover:border-gray-400'
                  }`}
                  style={{ backgroundColor: color.value }}
                  title={color.name}
                />
              ))}
            </div>
          </div>

          {/* Effects */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Effects</label>
            <div className="grid grid-cols-2 gap-2">
              {(['none', 'sparkle', 'glow', 'shadow'] as const).map((effect) => (
                <button
                  key={effect}
                  onClick={() => {
                    if (effect === 'none') {
                      updateConfig({ effects: [] });
                    } else {
                      const newEffects = config.effects.includes(effect)
                        ? config.effects.filter(e => e !== effect)
                        : [...config.effects.filter(e => e !== 'none'), effect];
                      updateConfig({ effects: newEffects });
                    }
                  }}
                  className={`px-3 py-2 text-xs uppercase tracking-widest transition-all duration-300 ${
                    config.effects.includes(effect)
                      ? 'bg-pink-600/50 text-pink-300 border border-pink-500'
                      : 'bg-gray-700/50 text-gray-300 border border-gray-600 hover:bg-gray-600/50'
                  }`}
                >
                  {effect}
                </button>
              ))}
            </div>
          </div>

          {/* Save Button */}
          {onSave && (
            <button
              onClick={() => onSave(config)}
              className="w-full px-4 py-3 text-sm uppercase tracking-widest transition-all duration-300
                       bg-green-600/50 text-green-300 border border-green-500 hover:bg-green-600/70 hover:text-white"
            >
              💎 Save Avatar (50 silk)
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
