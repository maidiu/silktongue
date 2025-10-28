// API helper functions for vocabulary operations

export interface VocabEntry {
  id: number;
  word: string;
  part_of_speech: string;
  modern_definition: string;
  usage_example?: string;
  synonyms?: string[];
  antonyms?: string[];
  collocations?: any;
  // Extended detail fields
  definitions?: {
    primary?: string;
    secondary?: string;
    tertiary?: string;
    [key: string]: string | undefined;
  };
  variant_forms?: string[];
  french_equivalent?: string;
  french_synonyms?: string[];
  french_root_cognates?: string[];
  russian_equivalent?: string;
  russian_synonyms?: string[];
  russian_root_cognates?: string[];
  common_collocations?: string[];
  cefr_level?: string;
  pronunciation?: string;
  is_mastered: boolean;
  learning_status: 'unmastered' | 'learned' | 'mastered';
  date_added?: string;
}

export interface UserStats {
  total_words: number;
  learned_count: number;
  mastered_count: number;
  unmastered_count: number;
}

export interface ScoreboardEntry {
  username: string;
  silk_balance: number;
  words_learned: number;
  words_mastered: number;
  total_silk_earned: number;
  quizzes_completed: number;
  avatar_config?: any;
}

export interface BeastModeStatus {
  status: 'locked' | 'available' | 'cooldown';
  cooldown_until?: string;
  completed_at?: string;
}

export interface DetailedVocabEntry extends VocabEntry {
  contrastive_opening?: string;
  structural_analysis?: string;
  timeline_events: TimelineEvent[];
  relations: WordRelation[];
  roots: RootFamily[];
}

export interface TimelineEvent {
  id: number;
  century?: string;
  year?: number;
  sense_at_time?: string;
  sibling_words?: string[];
  cultural_context?: string;
  causal_tensions?: string;
  language_transitions?: string;
  event_text: string;
  causal_tags?: string[];
}

export interface WordRelation {
  id: number;
  word: string;
  modern_definition: string;
  relation_type: string;
}

export interface RootFamily {
  root_word: string;
  language: string;
  meaning: string;
}

export async function getVocabEntries(params?: {
  sort?: 'date' | 'alpha';
  filter?: 'all' | 'learned' | 'unlearned';
}): Promise<VocabEntry[]> {
  const queryParams = new URLSearchParams();
  if (params?.sort) queryParams.append('sort', params.sort);
  if (params?.filter) queryParams.append('filter', params.filter);

  const res = await fetch(`/api/vocab?${queryParams.toString()}`);
  if (!res.ok) throw new Error('Failed to load vocabulary');
  return res.json();
}

export async function getVocabEntry(id: number): Promise<DetailedVocabEntry> {
  const res = await fetch(`/api/vocab/${id}`);
  if (!res.ok) throw new Error('Failed to load vocabulary entry');
  return res.json();
}

export async function searchVocab(query: string): Promise<VocabEntry[]> {
  const res = await fetch(`/api/vocab/search?q=${encodeURIComponent(query)}`);
  if (!res.ok) throw new Error('Failed to search vocabulary');
  return res.json();
}

export async function updateLearnedStatus(id: number, isMastered: boolean): Promise<void> {
  const res = await fetch(`/api/vocab/${id}/learned`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ is_mastered: isMastered }),
  });
  if (!res.ok) throw new Error('Failed to update learned status');
}

export async function exploreVocab(params?: {
  century?: string;
  tag?: string;
}): Promise<VocabEntry[]> {
  const queryParams = new URLSearchParams();
  if (params?.century) queryParams.append('century', params.century);
  if (params?.tag) queryParams.append('tag', params.tag);

  const res = await fetch(`/api/explore?${queryParams.toString()}`);
  if (!res.ok) throw new Error('Failed to explore vocabulary');
  return res.json();
}

export async function getTags(): Promise<Array<{ tag_name: string; description: string; usage_count: number }>> {
  const res = await fetch('/api/meta/tags');
  if (!res.ok) throw new Error('Failed to load tags');
  return res.json();
}

export async function getCenturies(): Promise<Array<{ century: string; word_count: number }>> {
  const res = await fetch('/api/meta/centuries');
  if (!res.ok) throw new Error('Failed to load centuries');
  return res.json();
}

export async function getUserStats(): Promise<UserStats> {
  const res = await fetch('/api/vocab/stats');
  if (!res.ok) throw new Error('Failed to load user stats');
  return res.json();
}

export async function getScoreboard(): Promise<ScoreboardEntry[]> {
  const res = await fetch('/api/vocab/scoreboard');
  if (!res.ok) throw new Error('Failed to load scoreboard');
  return res.json();
}

export async function getBeastModeStatus(wordId: number): Promise<BeastModeStatus> {
  const token = localStorage.getItem('token');
  const res = await fetch(`/api/vocab/beast-mode-status/${wordId}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  if (!res.ok) throw new Error('Failed to load beast mode status');
  return res.json();
}

