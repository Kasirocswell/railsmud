import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCharacterCreation } from '../../context/CharacterCreationContext';

const ChooseName: React.FC = () => {
  const [name, setName] = useState<string>('');
  const { setCharacterName } = useCharacterCreation();
  const navigate = useNavigate();

  const handleSubmit = () => {
    setCharacterName(name);
    navigate('/character-creation/race');
  };

  return (
    <div>
      <h1>Choose Your Character's Name</h1>
      <input 
        type="text" 
        value={name} 
        onChange={(e) => setName(e.target.value)} 
        placeholder="Enter your character's name"
      />
      <button onClick={handleSubmit}>Next</button>
    </div>
  );
};

export default ChooseName;
