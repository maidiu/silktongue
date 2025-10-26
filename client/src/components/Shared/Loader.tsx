export default function Loader() {
  return (
    <div className="flex flex-col items-center justify-center py-12">
      <div className="relative">
        <div className="animate-spin rounded-full h-16 w-16 border-2 border-transparent border-t-soul-400 border-r-soul-500"></div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-soul-400 text-2xl animate-pulse-slow">
          ✦
        </div>
      </div>
      <p className="mt-4 text-silk-300 text-sm">Weaving the threads...</p>
    </div>
  );
}

