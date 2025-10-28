interface SortFilterProps {
  sortBy: 'date' | 'alpha';
  filterBy: 'all' | 'learned' | 'unlearned';
  onSortChange: (sort: 'date' | 'alpha') => void;
  onFilterChange: (filter: 'all' | 'learned' | 'unlearned') => void;
}

export default function SortFilter({ 
  sortBy, 
  filterBy, 
  onSortChange, 
  onFilterChange 
}: SortFilterProps) {
  return (
    <div className="flex flex-wrap gap-4 items-center">
      {/* Sort Dropdown */}
      <div className="flex items-center gap-3">
        <label htmlFor="sort" className="text-sm text-gray-400 uppercase tracking-widest">
          Sort 
        </label> 
        <select
          id="sort"
          value={sortBy}
          onChange={(e) => onSortChange(e.target.value as 'date' | 'alpha')}
          className="px-4 py-2 bg-black/40 border-2 border-white/10 text-white focus:border-white/30 transition-all cursor-pointer hover:border-white/20 outline-none backdrop-blur-sm uppercase tracking-widest text-sm"
        >
          <option value="date" className="bg-black text-white">Date Added</option>
          <option value="alpha" className="bg-black text-white">Alphabetical</option>
        </select>
      </div>

      {/* Decorative divider */}
      <div className="h-6 w-px bg-white/10"></div>

      {/* Filter Dropdown */}
      <div className="flex items-center gap-3">
        <label htmlFor="filter" className="text-sm text-gray-400 uppercase tracking-widest">
          Show
        </label>
        <select
          id="filter"
          value={filterBy}
          onChange={(e) => onFilterChange(e.target.value as 'all' | 'learned' | 'unlearned')}
          className="px-4 py-2 bg-black/40 border-2 border-white/10 text-white focus:border-white/30 transition-all cursor-pointer hover:border-white/20 outline-none backdrop-blur-sm uppercase tracking-widest text-sm"
        >
          <option value="all" className="bg-black text-white">All Words</option>
          <option value="learned" className="bg-black text-white">Learned</option>
          <option value="unlearned" className="bg-black text-white">Unlearned</option>
        </select>
      </div>
    </div>
  );
}

