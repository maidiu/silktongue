import { useState } from 'react';
import SilksongAvatar, { defaultAvatarConfigs } from './SilksongAvatar';
import type { AvatarConfig } from './types';

interface AvatarCustomizerMobileProps {
  initialConfig?: AvatarConfig;
  onSave?: (config: AvatarConfig) => void;
  onClose?: () => void;
  userName?: string;
}

export default function AvatarCustomizerMobile({ 
  initialConfig = defaultAvatarConfigs.hornet, 
  onSave,
  onClose,
  userName
}: AvatarCustomizerMobileProps) {
  const [config, setConfig] = useState<AvatarConfig>(initialConfig);

  const updateConfig = (updates: Partial<AvatarConfig>) => {
    setConfig({ ...config, ...updates });
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
    <div className="fixed inset-0 bg-gray-900 z-[200] flex flex-col" style={{top:0, left:0, backgroundColor:'#000000', width:'100vw', height: '100vh'}}>
      {/* Header */}
      <div className="flex justify-between items-center p-4 border-b border-gray-700 bg-gray-800">
        <h2 className="text-xl font-display font-bold text-white">🎭 Customize Avatar</h2>
        <button
          onClick={onClose}
          className="text-gray-400 hover:text-white text-3xl p-2"
        >
          ×
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto p-4 space-y-6" style={{WebkitOverflowScrolling: 'touch', minHeight: 0}}>
        {/* Avatar Preview */}
        <div className="bg-gray-900 pb-4">
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700 flex justify-center">
            <SilksongAvatar config={config} size={150} />
          </div>
        </div>

        {/* Quick Presets */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Quick Presets</label>
          <div className="grid grid-cols-2 gap-2">
            {Object.entries(defaultAvatarConfigs).map(([name, preset]) => (
              <button
                key={name}
                onClick={() => updateConfig(preset)}
                className="px-4 py-3 text-sm uppercase tracking-widest font-bold
                         bg-gray-700 text-gray-300 border border-gray-600 hover:bg-gray-600 hover:text-white rounded-lg"
              >
                {name}
              </button>
            ))}
          </div>
        </div>

        {/* Body Type */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Body Type</label>
          <div className="grid grid-cols-3 gap-2">
            {(['hornet', 'knight', 'bug'] as const).map((body) => (
              <button
                key={body}
                onClick={() => updateConfig({ body })}
                className={`px-4 py-3 text-sm font-bold uppercase rounded-lg ${
                  config.body === body
                    ? 'bg-blue-600 text-white border-2 border-blue-400'
                    : 'bg-gray-700 text-gray-300 border-2 border-gray-600'
                }`}
              >
                {body}
              </button>
            ))}
          </div>
        </div>

        {/* Mask */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Mask</label>
          <div className="grid grid-cols-2 gap-2">
            {(['hornet', 'knight', 'void', 'crystal'] as const).map((mask) => (
              <button
                key={mask}
                onClick={() => updateConfig({ mask })}
                className={`px-4 py-3 text-sm font-bold uppercase rounded-lg ${
                  config.mask === mask
                    ? 'bg-green-600 text-white border-2 border-green-400'
                    : 'bg-gray-700 text-gray-300 border-2 border-gray-600'
                }`}
              >
                {mask}
              </button>
            ))}
          </div>
        </div>

        {/* Wings */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Wings</label>
          <div className="grid grid-cols-2 gap-2">
            {(['none', 'silk', 'void', 'crystal'] as const).map((wings) => (
              <button
                key={wings}
                onClick={() => updateConfig({ wings })}
                className={`px-4 py-3 text-sm font-bold uppercase rounded-lg ${
                  config.wings === wings
                    ? 'bg-purple-600 text-white border-2 border-purple-400'
                    : 'bg-gray-700 text-gray-300 border-2 border-gray-600'
                }`}
              >
                {wings}
              </button>
            ))}
          </div>
        </div>

        {/* Weapon */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Weapon</label>
          <div className="grid grid-cols-2 gap-2">
            {(['none', 'nail', 'needle', 'spell'] as const).map((weapon) => (
              <button
                key={weapon}
                onClick={() => updateConfig({ weapon })}
                className={`px-4 py-3 text-sm font-bold uppercase rounded-lg ${
                  config.weapon === weapon
                    ? 'bg-orange-600 text-white border-2 border-orange-400'
                    : 'bg-gray-700 text-gray-300 border-2 border-gray-600'
                }`}
              >
                {weapon}
              </button>
            ))}
          </div>
        </div>

        {/* Primary Color */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Primary Color</label>
          <div className="grid grid-cols-4 gap-3">
            {colorOptions.map((color) => (
              <button
                key={color.value}
                onClick={() => updateConfig({ primaryColor: color.value })}
                className={`w-full aspect-square rounded-lg border-4 ${
                  config.primaryColor === color.value ? 'border-white' : 'border-gray-600'
                }`}
                style={{ backgroundColor: color.value }}
                title={color.name}
              />
            ))}
          </div>
        </div>

        {/* Accent Color */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Accent Color</label>
          <div className="grid grid-cols-4 gap-3">
            {colorOptions.map((color) => (
              <button
                key={color.value}
                onClick={() => updateConfig({ accentColor: color.value })}
                className={`w-full aspect-square rounded-lg border-4 ${
                  config.accentColor === color.value ? 'border-white' : 'border-gray-600'
                }`}
                style={{ backgroundColor: color.value }}
                title={color.name}
              />
            ))}
          </div>
        </div>

        {/* Effects */}
        <div>
          <label className="block text-sm font-bold text-gray-300 mb-3 uppercase">Effects</label>
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
                className={`px-4 py-3 text-sm font-bold uppercase rounded-lg ${
                  config.effects.includes(effect)
                    ? 'bg-pink-600 text-white border-2 border-pink-400'
                    : 'bg-gray-700 text-gray-300 border-2 border-gray-600'
                }`}
              >
                {effect}
              </button>
            ))}
          </div>
        </div>
      </div>

      
        {/* Save Button - Inside scrollable content */}
        {onSave && (
          <div className="pt-4 pb-2">
            <button
              onClick={() => onSave(config)}
              className="w-full px-6 py-4 text-lg font-bold uppercase
                       bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              💎 Save Avatar (50 silk)
            </button>
          </div>
        )}
    </div>
  );
}

