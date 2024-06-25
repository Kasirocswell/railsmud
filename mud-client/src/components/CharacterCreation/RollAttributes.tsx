import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCharacterCreation } from '../../context/CharacterCreationContext';

const rollAttributes = () => {
  return Array.from({ length: 8 }, () => Math.floor(Math.random() * 9) + 1);
};

const attributeLabels = [
  'Strength',
  'Dexterity',
  'Constitution',
  'Intelligence',
  'Wisdom',
  'Charisma',
  'Luck',
  'Speed'
];

const RollAttributes: React.FC = () => {
  const { setCharacterAttributes } = useCharacterCreation();
  const [attributes, setAttributes] = useState<number[]>(rollAttributes());
  const [rerolls, setRerolls] = useState<number>(2);
  const navigate = useNavigate();

  const handleReroll = () => {
    if (rerolls > 0) {
      setAttributes(rollAttributes());
      setRerolls(rerolls - 1);
    }
  };

  const handleConfirm = () => {
    setCharacterAttributes(attributes);
    navigate('/character-creation/summary');
  };

  return (
    <div>
      <h1>Roll Your Attributes</h1>
      <p>Your attributes are randomly generated between 1 and 9. You have two rerolls if you don't like the initial roll.</p>
      <div>
        {attributes.map((attr, index) => (
          <div key={index} style={{ margin: '0 5px' }}>
            <strong>{attributeLabels[index]}: </strong>{attr}
          </div>
        ))}
      </div>
      <button onClick={handleReroll} disabled={rerolls === 0}>
        Reroll ({rerolls} remaining)
      </button>
      <button onClick={handleConfirm}>Confirm</button>
    </div>
  );
};

export default RollAttributes;
