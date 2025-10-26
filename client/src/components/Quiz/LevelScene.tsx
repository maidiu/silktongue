import type { ReactNode } from 'react';

interface LevelSceneProps {
  title: string;
  instruction: string;
  children: ReactNode;
}

export default function LevelScene({ title, instruction, children }: LevelSceneProps) {
  return (
    <div className="flex flex-col items-center justify-center gap-6 text-center px-4 max-w-4xl mx-auto">
      <h2 className="text-3xl font-display font-bold tracking-wide text-white">
        {title}
      </h2>
      <p className="text-gray-300 text-lg max-w-2xl leading-relaxed">
        {instruction}
      </p>
      <div className="mt-6 w-full">
        {children}
      </div>
    </div>
  );
}

