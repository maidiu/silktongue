interface EmptyStateProps {
  message: string;
}

export default function EmptyState({ message }: EmptyStateProps) {
  return (
    <div className="text-center py-16">
      <div className="inline-block mb-4 text-6xl text-soul-500/30 animate-pulse-slow">
        ✦
      </div>
      <p className="text-silk-300 text-lg font-light">{message}</p>
      <p className="text-silk-500 text-sm mt-2 italic">The threads remain unspun...</p>
    </div>
  );
}

