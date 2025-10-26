import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import WordExplorationModal from '../components/Maps/WordExplorationModal';

const WordExplorationPage: React.FC = () => {
  console.log('🚀 WordExplorationPage component loaded!');
  const { wordId } = useParams<{ wordId: string }>();
  console.log('🚀 wordId from params:', wordId);
  const navigate = useNavigate();
  const [wordData, setWordData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchWordData = async () => {
      console.log('WordExplorationPage: Starting fetch for wordId:', wordId);
      try {
        const url = `/api/vocab/${wordId}`;
        console.log('WordExplorationPage: Fetching URL:', url);
        
        const response = await fetch(url, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        
        console.log('WordExplorationPage: Response status:', response.status);
        
        if (response.ok) {
          const data = await response.json();
          console.log('WordExplorationPage: Word data fetched:', data);
          console.log('WordExplorationPage: Story data:', data.story);
          console.log('WordExplorationPage: Story length:', data.story?.length);
          console.log('WordExplorationPage: Story intro:', data.story_intro);
          setWordData(data);
        } else {
          console.error('WordExplorationPage: Response not ok:', response.status, response.statusText);
        }
      } catch (error) {
        console.error('WordExplorationPage: Error fetching word data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (wordId) {
      fetchWordData();
    } else {
      console.log('WordExplorationPage: No wordId provided');
    }
  }, [wordId]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Loading...</div>
      </div>
    );
  }

  if (!wordData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Word not found</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 flex items-center justify-center p-8">
      <WordExplorationModal
        word={wordData.word}
        wordId={wordData.id}
        definitions={wordData.definitions || []}
        synonyms={wordData.synonyms || []}
        antonyms={wordData.antonyms || []}
        etymology={wordData.etymology}
        story={wordData.timeline_events || []}
        story_intro={wordData.story_intro}
        onClose={() => navigate('/maps')}
        onComplete={() => navigate(`/quiz/${wordData.id}`)}
      />
    </div>
  );
};

export default WordExplorationPage;

