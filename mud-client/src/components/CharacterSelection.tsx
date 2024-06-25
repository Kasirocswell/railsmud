import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchCharacters, deleteCharacter } from '../services/api';

const CharacterSelection: React.FC = () => {
  const [characters, setCharacters] = useState<any[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    const getCharacters = async () => {
      try {
        const data = await fetchCharacters();
        setCharacters(data);
      } catch (error) {
        console.error("Failed to fetch characters", error);
      }
    };
    getCharacters();
  }, []);

  const handleSelectCharacter = (characterId: number) => {
    navigate(`/game/${characterId}`);
  };

  const handleDeleteCharacter = async (characterId: number) => {
    try {
      await deleteCharacter(characterId);
      setCharacters(characters.filter(character => character.id !== characterId));
    } catch (error) {
      console.error("Failed to delete character", error);
    }
  };

  return (
    <div>
      <h1>Select Your Character</h1>
      <ul>
        {characters.map((character) => (
          <li key={character.id}>
            <button onClick={() => handleSelectCharacter(character.id)}>
              {character.name}
            </button>
            <button onClick={() => handleDeleteCharacter(character.id)}>
              Delete
            </button>
          </li>
        ))}
      </ul>
      <button onClick={() => navigate('/character-creation')}>
        Create New Character
      </button>
    </div>
  );
};

export default CharacterSelection;
