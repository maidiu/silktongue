import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Layout from '../components/Layout/Layout';

interface DialogueEntry {
  paragraph: string;
  word: string;
}

interface GuardianData {
  floor: number;
  guardian: string;
  intro: string;
  dialogue: DialogueEntry[];
  completion: string;
}

export default function GuardianPage() {
  const { floor } = useParams<{ floor: string }>();
  const navigate = useNavigate();
  
  const [guardianData, setGuardianData] = useState<GuardianData | null>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [currentAnswer, setCurrentAnswer] = useState('');
  const [showCompletion, setShowCompletion] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadGuardianData = async () => {
      try {
        // Map floor numbers to guardian names
        const guardianNames: { [key: string]: string } = {
          '1': 'mason',
          '2': 'jurist',
        };
        
        const guardianName = guardianNames[floor || '1'] || 'mason';
        const response = await fetch(`/guardians/floor${floor}_${guardianName}.json`);
        if (!response.ok) {
          throw new Error('Failed to load guardian data');
        }
        const data = await response.json();
        setGuardianData(data);
      } catch (err) {
        setError('Failed to load guardian challenge');
        console.error('Error loading guardian data:', err);
      } finally {
        setLoading(false);
      }
    };

    loadGuardianData();
  }, [floor]);

  const handleSubmit = () => {
    if (!guardianData) return;

    const currentDialogue = guardianData.dialogue[currentIndex];
    const isCorrect = currentAnswer.toLowerCase().trim() === currentDialogue.word.toLowerCase();
    
    if (isCorrect) {
      setCurrentAnswer('');
      setError('');
      
      if (currentIndex === guardianData.dialogue.length - 1) {
        setShowCompletion(true);
      } else {
        setCurrentIndex(currentIndex + 1);
      }
    } else {
      setError(`Not quite. The word "${currentDialogue.word}" is needed here.`);
    }
  };

  const handleFinalComplete = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/maps/unlock-next-floor', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ currentFloor: guardianData?.floor }),
      });

      if (!response.ok) {
        throw new Error('Failed to unlock next floor');
      }

      navigate('/maps');
    } catch (err) {
      console.error('Error unlocking next floor:', err);
      setError('Failed to unlock next floor');
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-2xl text-white">Loading guardian challenge...</div>
        </div>
      </Layout>
    );
  }

  if (error && !guardianData) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-2xl text-red-400">{error}</div>
        </div>
      </Layout>
    );
  }

  if (!guardianData) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-2xl text-white">Guardian data not found</div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="bg-gray-800/90 rounded-lg border-2 border-red-600 p-8">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold text-red-400 mb-2">{guardianData.guardian}</h1>
            <p className="text-gray-300">Floor {guardianData.floor} Guardian Challenge</p>
          </div>

          {!showCompletion ? (
            <>
              {/* Intro (shown only at start) */}
              {currentIndex === 0 && (
                <div className="mb-8 p-6 bg-gray-900/50 rounded border border-gray-700">
                  <p className="text-lg text-gray-200 leading-relaxed whitespace-pre-line">
                    {guardianData.intro}
                  </p>
                </div>
              )}

              {/* Current dialogue paragraph */}
              <div className="mb-8 p-6 bg-gray-900/50 rounded border border-gray-700">
                <p className="text-lg text-gray-200 leading-relaxed whitespace-pre-line">
                  {guardianData.dialogue[currentIndex].paragraph}
                </p>
              </div>

              {/* Input section */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    What is the word?
                  </label>
                  <input
                    type="text"
                    value={currentAnswer}
                    onChange={(e) => setCurrentAnswer(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && handleSubmit()}
                    className="w-full px-4 py-3 bg-gray-900 border border-gray-600 rounded text-white text-lg focus:outline-none focus:border-red-500"
                    placeholder="Type the missing word..."
                    autoFocus
                  />
                </div>

                {error && (
                  <div className="text-red-400 text-sm">{error}</div>
                )}

                <button
                  onClick={handleSubmit}
                  className="w-full px-6 py-3 bg-red-600 hover:bg-red-700 text-white font-semibold rounded transition-colors"
                >
                  Submit Word
                </button>

                <div className="text-center text-sm text-gray-400">
                  Word {currentIndex + 1} of {guardianData.dialogue.length}
                </div>
              </div>
            </>
          ) : (
            /* Completion */
            <div className="space-y-6">
              <div className="p-6 bg-green-900/30 rounded border border-green-600">
                <p className="text-lg text-gray-200 leading-relaxed whitespace-pre-line">
                  {guardianData.completion}
                </p>
              </div>

              <button
                onClick={handleFinalComplete}
                className="w-full px-6 py-4 bg-green-600 hover:bg-green-700 text-white font-bold text-lg rounded transition-colors"
              >
                Ascend to Floor {guardianData.floor + 1}
              </button>
            </div>
          )}
        </div>

        {/* Back button */}
        <div className="mt-6 text-center">
          <button
            onClick={() => navigate('/maps')}
            className="text-gray-400 hover:text-white transition-colors"
          >
            ← Back to Map
          </button>
        </div>
      </div>
    </Layout>
  );
}

