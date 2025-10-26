export interface AvatarConfig {
  // Core character parts
  body: 'hornet' | 'knight' | 'bug';
  mask: 'hornet' | 'knight' | 'void' | 'crystal';
  wings: 'silk' | 'void' | 'crystal' | 'none';
  weapon: 'nail' | 'needle' | 'spell' | 'none';
  
  // Colors
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
  
  // Effects
  effects: ('sparkle' | 'glow' | 'shadow' | 'none')[];
}
