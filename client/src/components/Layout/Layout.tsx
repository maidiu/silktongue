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
      <main className="relative z-10 p-8">
        {children}
      </main>
    </div>
  );
}

