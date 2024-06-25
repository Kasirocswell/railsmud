import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useCharacterCreation } from '../../context/CharacterCreationContext';

const races = [
  { name: 'Human', description: 'Versatile and resilient, humans are adept at surviving in various environments. +2 Luck, +2 Charisma' },
  { name: 'Draconian', description: 'A race of dragon-like beings, known for their strength and fiery breath. +2 Strength, +2 Constitution' },
  { name: 'Zelorian', description: 'A highly intelligent race with a natural affinity for technology and engineering. +2 Intelligence, +2 Dexterity' },
  { name: 'Aethian', description: 'Ethereal beings with a strong connection to the psychic realm. +2 Wisdom, +2 Charisma' },
  { name: 'Rylothian', description: 'A warrior race known for their agility and combat skills. +2 Strength, +2 Dexterity' },
];

const ChooseRace: React.FC = () => {
  const navigate = useNavigate();
  const { setCharacterRace } = useCharacterCreation();

  const handleRaceSelection = (race: string) => {
    setCharacterRace(race);
    navigate('/character-creation/class');
  };

  return (
    <div>
      <h1>Choose Your Race</h1>
      <ul>
        {races.map((race) => (
          <li key={race.name}>
            <button onClick={() => handleRaceSelection(race.name)}>{race.name}</button>
            <p>{race.description}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ChooseRace;
