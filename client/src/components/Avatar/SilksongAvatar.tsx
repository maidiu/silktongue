// No imports needed
import type { AvatarConfig } from './types';

interface SilksongAvatarProps {
  config: AvatarConfig;
  size?: number;
  className?: string;
}

export default function SilksongAvatar({ config, size = 64, className = '' }: SilksongAvatarProps) {
  const svgSize = size;
  const centerX = svgSize / 2;
  const centerY = svgSize / 2;

  const getBodySVG = () => {
    switch (config.body) {
      case 'hornet':
        return (
          <g>
            {/* Hornet body */}
            <ellipse cx={centerX} cy={centerY + 8} rx="16" ry="20" fill={config.primaryColor} />
            <ellipse cx={centerX} cy={centerY - 2} rx="12" ry="14" fill={config.secondaryColor} />
            {/* Hornet head */}
            <circle cx={centerX} cy={centerY - 16} r="8" fill={config.primaryColor} />
          </g>
        );
      case 'knight':
        return (
          <g>
            {/* Knight body */}
            <rect x={centerX - 12} y={centerY - 4} width="24" height="28" rx="3" fill={config.primaryColor} />
            <rect x={centerX - 10} y={centerY - 2} width="20" height="22" rx="2" fill={config.secondaryColor} />
            {/* Knight head */}
            <circle cx={centerX} cy={centerY - 16} r="8" fill={config.primaryColor} />
          </g>
        );
      case 'bug':
        return (
          <g>
            {/* Bug body */}
            <ellipse cx={centerX} cy={centerY + 4} rx="14" ry="18" fill={config.primaryColor} />
            <ellipse cx={centerX} cy={centerY - 4} rx="10" ry="12" fill={config.secondaryColor} />
            {/* Bug head */}
            <circle cx={centerX} cy={centerY - 18} r="7" fill={config.primaryColor} />
          </g>
        );
      default:
        return null;
    }
  };

  const getMaskSVG = () => {
    switch (config.mask) {
      case 'hornet':
        return (
          <g>
            {/* Hornet mask */}
            <path d={`M ${centerX - 8} ${centerY - 18} Q ${centerX} ${centerY - 22} ${centerX + 8} ${centerY - 18}`} 
                  stroke={config.accentColor} strokeWidth="2" fill="none" />
            <circle cx={centerX - 3} cy={centerY - 16} r="1" fill={config.accentColor} />
            <circle cx={centerX + 3} cy={centerY - 16} r="1" fill={config.accentColor} />
          </g>
        );
      case 'knight':
        return (
          <g>
            {/* Knight helmet */}
            <path d={`M ${centerX - 6} ${centerY - 18} L ${centerX - 8} ${centerY - 12} L ${centerX + 8} ${centerY - 12} L ${centerX + 6} ${centerY - 18}`} 
                  fill={config.accentColor} />
            <rect x={centerX - 2} y={centerY - 16} width="4" height="2" fill={config.primaryColor} />
          </g>
        );
      case 'void':
        return (
          <g>
            {/* Void mask */}
            <circle cx={centerX} cy={centerY - 16} r="6" fill="none" stroke={config.accentColor} strokeWidth="2" />
            <circle cx={centerX} cy={centerY - 16} r="3" fill={config.accentColor} opacity="0.3" />
          </g>
        );
      case 'crystal':
        return (
          <g>
            {/* Crystal mask */}
            <polygon points={`${centerX},${centerY - 22} ${centerX - 6},${centerY - 16} ${centerX + 6},${centerY - 16}`} 
                     fill={config.accentColor} opacity="0.8" />
            <polygon points={`${centerX},${centerY - 20} ${centerX - 4},${centerY - 16} ${centerX + 4},${centerY - 16}`} 
                     fill={config.accentColor} />
          </g>
        );
      default:
        return null;
    }
  };

  const getWingsSVG = () => {
    if (config.wings === 'none') return null;
    
    switch (config.wings) {
      case 'silk':
        return (
          <g>
            {/* Silk wings */}
            <ellipse cx={centerX - 16} cy={centerY - 8} rx="8" ry="12" fill={config.accentColor} opacity="0.6" />
            <ellipse cx={centerX + 16} cy={centerY - 8} rx="8" ry="12" fill={config.accentColor} opacity="0.6" />
            <path d={`M ${centerX - 16} ${centerY - 8} Q ${centerX - 12} ${centerY - 4} ${centerX - 8} ${centerY - 8}`} 
                  stroke={config.accentColor} strokeWidth="1" fill="none" />
            <path d={`M ${centerX + 16} ${centerY - 8} Q ${centerX + 12} ${centerY - 4} ${centerX + 8} ${centerY - 8}`} 
                  stroke={config.accentColor} strokeWidth="1" fill="none" />
          </g>
        );
      case 'void':
        return (
          <g>
            {/* Void wings */}
            <ellipse cx={centerX - 16} cy={centerY - 8} rx="8" ry="12" fill="none" stroke={config.accentColor} strokeWidth="2" />
            <ellipse cx={centerX + 16} cy={centerY - 8} rx="8" ry="12" fill="none" stroke={config.accentColor} strokeWidth="2" />
            <circle cx={centerX - 16} cy={centerY - 8} r="2" fill={config.accentColor} />
            <circle cx={centerX + 16} cy={centerY - 8} r="2" fill={config.accentColor} />
          </g>
        );
      case 'crystal':
        return (
          <g>
            {/* Crystal wings */}
            <polygon points={`${centerX - 20},${centerY - 12} ${centerX - 12},${centerY - 4} ${centerX - 16},${centerY - 8}`} 
                     fill={config.accentColor} opacity="0.7" />
            <polygon points={`${centerX + 20},${centerY - 12} ${centerX + 12},${centerY - 4} ${centerX + 16},${centerY - 8}`} 
                     fill={config.accentColor} opacity="0.7" />
          </g>
        );
      default:
        return null;
    }
  };

  const getWeaponSVG = () => {
    if (config.weapon === 'none') return null;
    
    switch (config.weapon) {
      case 'nail':
        return (
          <g>
            {/* Nail - much larger and more dramatic */}
            <line x1={centerX + 15} y1={centerY - 12} x2={centerX + 15} y2={centerY + 25} 
                  stroke={config.accentColor} strokeWidth="4" />
            <rect x={centerX + 12} y={centerY + 25} width="6" height="12" fill={config.accentColor} />
            <rect x={centerX + 11} y={centerY + 20} width="8" height="3" fill={config.accentColor} opacity="0.7" />
            <rect x={centerX + 10} y={centerY - 8} width="10" height="8" fill={config.accentColor} />
          </g>
        );
      case 'needle':
        return (
          <g>
            {/* Needle - much more dramatic */}
            <line x1={centerX + 15} y1={centerY - 12} x2={centerX + 15} y2={centerY + 25} 
                  stroke={config.accentColor} strokeWidth="3" />
            <circle cx={centerX + 15} cy={centerY - 12} r="4" fill={config.accentColor} />
            <circle cx={centerX + 15} cy={centerY - 12} r="2" fill="white" />
            <circle cx={centerX + 15} cy={centerY + 25} r="3" fill={config.accentColor} opacity="0.8" />
          </g>
        );
      case 'spell':
        return (
          <g>
            {/* Spell effect - much more dramatic */}
            <circle cx={centerX + 15} cy={centerY} r="8" fill={config.accentColor} opacity="0.3">
              <animate attributeName="opacity" values="0.3;0.8;0.3" dur="2s" repeatCount="indefinite" />
            </circle>
            <circle cx={centerX + 15} cy={centerY} r="6" fill={config.accentColor} opacity="0.6">
              <animate attributeName="opacity" values="0.6;0.9;0.6" dur="1.5s" repeatCount="indefinite" />
            </circle>
            <circle cx={centerX + 15} cy={centerY} r="4" fill={config.accentColor} />
            <circle cx={centerX + 15} cy={centerY} r="2" fill="white" />
            <circle cx={centerX + 15} cy={centerY} r="1" fill="white" opacity="0.8">
              <animate attributeName="opacity" values="0.8;1;0.8" dur="1s" repeatCount="indefinite" />
            </circle>
          </g>
        );
      default:
        return null;
    }
  };

  const getEffectsSVG = () => {
    return config.effects.map((effect, index) => {
      switch (effect) {
        case 'sparkle':
          return (
            <g key={index}>
              <circle cx={centerX - 25} cy={centerY - 25} r="4" fill="#FFD700" opacity="0.9">
                <animate attributeName="opacity" values="0.9;0.3;0.9" dur="2s" repeatCount="indefinite" />
              </circle>
              <circle cx={centerX + 25} cy={centerY - 20} r="3" fill="#FFD700" opacity="0.8">
                <animate attributeName="opacity" values="0.8;0.2;0.8" dur="1.5s" repeatCount="indefinite" />
              </circle>
              <circle cx={centerX + 20} cy={centerY + 25} r="2.5" fill="#FFD700" opacity="0.7">
                <animate attributeName="opacity" values="0.7;0.3;0.7" dur="1.8s" repeatCount="indefinite" />
              </circle>
              <circle cx={centerX - 15} cy={centerY + 20} r="3.5" fill="#FFD700" opacity="0.8">
                <animate attributeName="opacity" values="0.8;0.2;0.8" dur="1.3s" repeatCount="indefinite" />
              </circle>
              <circle cx={centerX} cy={centerY - 30} r="2" fill="#FFD700" opacity="0.6">
                <animate attributeName="opacity" values="0.6;0.1;0.6" dur="2.2s" repeatCount="indefinite" />
              </circle>
            </g>
          );
        case 'glow':
          return (
            <g key={index}>
              <circle cx={centerX} cy={centerY} r="35" fill="none" stroke="#00FFFF" strokeWidth="4" opacity="0.8">
                <animate attributeName="opacity" values="0.8;0.3;0.8" dur="3s" repeatCount="indefinite" />
              </circle>
              <circle cx={centerX} cy={centerY} r="25" fill="none" stroke="#00FFFF" strokeWidth="2" opacity="0.6">
                <animate attributeName="opacity" values="0.6;0.2;0.6" dur="2s" repeatCount="indefinite" />
              </circle>
            </g>
          );
        case 'shadow':
          return (
            <g key={index}>
              <ellipse cx={centerX + 3} cy={centerY + 20} rx="18" ry="6" fill="#000000" opacity="0.5" />
              <ellipse cx={centerX + 1} cy={centerY + 18} rx="15" ry="4" fill="#000000" opacity="0.3" />
            </g>
          );
        default:
          return null;
      }
    });
  };

  return (
    <svg width={svgSize} height={svgSize} className={className} viewBox={`0 0 ${svgSize} ${svgSize}`}>
      {/* Effects layer (behind) */}
      {getEffectsSVG()}
      
      {/* Wings layer */}
      {getWingsSVG()}
      
      {/* Body layer */}
      {getBodySVG()}
      
      {/* Mask layer */}
      {getMaskSVG()}
      
      {/* Weapon layer */}
      {getWeaponSVG()}
    </svg>
  );
}

// Default configurations
export const defaultAvatarConfigs: Record<string, AvatarConfig> = {
  hornet: {
    body: 'hornet',
    mask: 'hornet',
    wings: 'silk',
    weapon: 'needle',
    primaryColor: '#2d1b2d',
    secondaryColor: '#4a2c4a',
    accentColor: '#ff6b6b',
    effects: ['sparkle']
  },
  knight: {
    body: 'knight',
    mask: 'knight',
    wings: 'none',
    weapon: 'nail',
    primaryColor: '#1a1a2e',
    secondaryColor: '#16213e',
    accentColor: '#0f3460',
    effects: ['glow']
  },
  void: {
    body: 'bug',
    mask: 'void',
    wings: 'void',
    weapon: 'spell',
    primaryColor: '#0d1117',
    secondaryColor: '#161b22',
    accentColor: '#7c3aed',
    effects: ['shadow', 'glow']
  },
  crystal: {
    body: 'hornet',
    mask: 'crystal',
    wings: 'crystal',
    weapon: 'spell',
    primaryColor: '#1e1e2e',
    secondaryColor: '#2d2d44',
    accentColor: '#00d4aa',
    effects: ['sparkle', 'glow']
  }
};
