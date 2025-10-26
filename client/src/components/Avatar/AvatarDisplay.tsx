import SilksongAvatar, { defaultAvatarConfigs } from './SilksongAvatar';
import type { AvatarConfig } from './types';

interface AvatarDisplayProps {
  config?: AvatarConfig;
  size?: number;
  className?: string;
  onClick?: () => void;
}

export default function AvatarDisplay({ 
  config = defaultAvatarConfigs.hornet, 
  size = 40, 
  className = '',
  onClick 
}: AvatarDisplayProps) {
  return (
    <div 
      className={`cursor-pointer transition-all duration-300 hover:scale-110 ${className}`}
      onClick={onClick}
    >
      <SilksongAvatar config={config} size={size} />
    </div>
  );
}
