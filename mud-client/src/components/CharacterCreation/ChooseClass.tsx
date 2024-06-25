import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useCharacterCreation } from '../../context/CharacterCreationContext';

const classes = [
  { name: 'Soldier', description: 'Trained in combat and warfare, soldiers are the backbone of any fighting force.  +3 Strength, +3 Constitution' },
  { name: 'Medic', description: 'Skilled in medical practices, medics are essential for healing and support. +3 Wisdom, +3 Charisma' },
  { name: 'Pilot', description: 'Expert pilots capable of maneuvering through space with ease. +3 Dexterity, +3 Intelligence' },
  { name: 'Engineer', description: 'Master of technology and machinery, engineers keep everything running smoothly. +3 Intelligence, +3 Wisdom' },
];

const ChooseClass: React.FC = () => {
  const navigate = useNavigate();
  const { setCharacterClass } = useCharacterCreation();

  const handleClassSelection = (className: string) => {
    setCharacterClass(className);
    navigate('/character-creation/attributes');
  };

  return (
    <div>
      <h1>Choose Your Class</h1>
      <ul>
        {classes.map((cls) => (
          <li key={cls.name}>
            <button onClick={() => handleClassSelection(cls.name)}>{cls.name}</button>
            <p>{cls.description}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ChooseClass;
