import { useEffect, useState } from 'react';
import { toOrdinal } from '../../utils/ordinals';

interface Tag {
  tag_name: string;
  description: string;
  usage_count: number;
}

interface Century {
  century: string;
  word_count: number;
}

interface TagCenturyFilterProps {
  selectedCentury: string;
  selectedTag: string;
  onCenturyChange: (century: string) => void;
  onTagChange: (tag: string) => void;
}

export default function TagCenturyFilter({ 
  selectedCentury, 
  selectedTag, 
  onCenturyChange, 
  onTagChange 
}: TagCenturyFilterProps) {
  const [tags, setTags] = useState<Tag[]>([]);
  const [centuries, setCenturies] = useState<Century[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMetadata = async () => {
      try {
        const [tagsRes, centuriesRes] = await Promise.all([
          fetch('/api/meta/tags'),
          fetch('/api/meta/centuries')
        ]);
        const tagsData = await tagsRes.json();
        const centuriesData = await centuriesRes.json();
        setTags(tagsData);
        setCenturies(centuriesData);
      } catch (err) {
        console.error('Error loading metadata:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchMetadata();
  }, []);

  if (loading) {
    return (
      <div className="text-silk-400 flex items-center gap-2">
        <span className="animate-pulse-slow">✦</span> Loading filters...
      </div>
    );
  }

  return (
    <div className="flex flex-wrap gap-4 items-center">
      {/* Century Dropdown */}
      <div className="flex items-center gap-3">
        <label htmlFor="century" className="text-sm text-gray-400 uppercase tracking-widest">
          Century
        </label>
        <select
          id="century"
          value={selectedCentury}
          onChange={(e) => onCenturyChange(e.target.value)}
          className="px-4 py-2 bg-black/40 border-2 border-white/10 text-white focus:border-white/30 transition-all cursor-pointer hover:border-white/20 outline-none backdrop-blur-sm uppercase tracking-widest text-sm min-w-[180px]"
        >
          <option value="" className="bg-black text-white">All Centuries</option>
          {centuries.map((c) => (
            <option key={c.century} value={c.century} className="bg-black text-white">
              {toOrdinal(c.century)} ({c.word_count})
            </option>
          ))}
        </select>
      </div>

      {/* Decorative divider */}
      <div className="h-6 w-px bg-white/10"></div>

      {/* Tag Dropdown */}
      <div className="flex items-center gap-3">
        <label htmlFor="tag" className="text-sm text-gray-400 uppercase tracking-widest">
          Pattern
        </label>
        <select
          id="tag"
          value={selectedTag}
          onChange={(e) => onTagChange(e.target.value)}
          className="px-4 py-2 bg-black/40 border-2 border-white/10 text-white focus:border-white/30 transition-all cursor-pointer hover:border-white/20 outline-none backdrop-blur-sm uppercase tracking-widest text-sm min-w-[220px]"
        >
          <option value="" className="bg-black text-white">All Patterns</option>
          {tags.map((tag) => (
            <option key={tag.tag_name} value={tag.tag_name} className="bg-black text-white">
              {tag.tag_name.replace(/_/g, ' ')} ({tag.usage_count})
            </option>
          ))}
        </select>
      </div>
    </div>
  );
}

