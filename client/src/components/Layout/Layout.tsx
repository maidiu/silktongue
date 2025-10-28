import type { ReactNode } from 'react';
import Header from './Header';

interface LayoutProps {
  children: ReactNode;
  onSearch?: (query: string) => void;
}

export default function Layout({ children, onSearch }: LayoutProps) {
  return (
    <div className="min-h-screen relative">
      <Header onSearch={onSearch} />
      <main className="relative z-10 p-4 sm:p-6 lg:p-8" style={{marginLeft: '1rem', marginRight: '1rem'}}>
        {children}
      </main>
    </div>
  );
}

