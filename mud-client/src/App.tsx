import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './components/Login';
import Register from './components/Register';
import Game from './components/Game';
import CharacterSelection from './components/CharacterSelection';
import CharacterCreationOverview from './components/CharacterCreation/CharacterCreationOverview';
import ChooseName from './components/CharacterCreation/ChooseName';
import ChooseRace from './components/CharacterCreation/ChooseRace';
import ChooseClass from './components/CharacterCreation/ChooseClass';
import RollAttributes from './components/CharacterCreation/RollAttributes';
import CharacterSummary from './components/CharacterCreation/CharacterSummary';
import { CharacterCreationProvider } from './context/CharacterCreationContext';


const App: React.FC = () => {

  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/characters" element={<CharacterSelection />} />
          <Route path="/game/:characterId" element={<Game />} />
          <Route path="/" element={<Login />} />
          
          {/* Character creation routes wrapped with CharacterCreationProvider */}
          <Route
            path="/character-creation/*"
            element={
              <CharacterCreationProvider>
                <Routes>
                  <Route path="/" element={<CharacterCreationOverview />} />
                  <Route path="name" element={<ChooseName />} />
                  <Route path="race" element={<ChooseRace />} />
                  <Route path="class" element={<ChooseClass />} />
                  <Route path="attributes" element={<RollAttributes />} />
                  <Route path="summary" element={<CharacterSummary />} />
                </Routes>
              </CharacterCreationProvider>
            }
          />
        </Routes>
      </Router>
    </AuthProvider>
  );
};

export default App;
