import React from 'react';
import { useNavigate } from 'react-router-dom';

const CharacterCreationOverview: React.FC = () => {
  const navigate = useNavigate();

  const startCharacterCreation = () => {
    navigate('/character-creation/name');
  };

  return (
    <div>
      <h1>Character Creation</h1>
      <p>Welcome to the space MUD character creation process. You will go through several steps to create your character, including choosing a race, class, and rolling for your attributes. Let's get started!</p>
      <button onClick={startCharacterCreation}>Start Character Creation</button>
    </div>
  );
};

export default CharacterCreationOverview;
