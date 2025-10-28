import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import HomePage from './pages/HomePage';
import ExplorerPage from './pages/ExplorerPage';
import WordDetailPage from './pages/WordDetailPage';
import QuizPage from './pages/QuizPage';
import LoginPage from './pages/LoginPage';
import AvatarPage from './pages/AvatarPage';
import MapsPage from './pages/MapsPage';
import WordExplorationPage from './pages/WordExplorationPage';
import RoomDetailsPage from './pages/RoomDetailsPage';
import GuardianPage from './pages/GuardianPage';
import './App.css';

function AppContent() {
  const { isAuthenticated, login } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage onLogin={login} />;
  }

  return (
    <Routes>
      <Route path="/" element={<MapsPage />} />
      <Route path="/explore" element={<ExplorerPage />} />
      <Route path="/home" element={<HomePage />} />
      <Route path="/word/:id" element={<WordDetailPage />} />
      <Route path="/quiz/:wordId" element={<QuizPage />} />
      <Route path="/avatar" element={<AvatarPage />} />
      <Route path="/maps" element={<MapsPage />} />
      <Route path="/word-exploration/:wordId" element={<WordExplorationPage />} />
      <Route path="/room-details/:roomId" element={<RoomDetailsPage />} />
      <Route path="/guardian/:floor" element={<GuardianPage />} />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <AppContent />
      </Router>
    </AuthProvider>
  );
}

export default App;
