import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useCharacterCreation } from '../../context/CharacterCreationContext';
import { createCharacter } from '../../services/api';

const CharacterSummary: React.FC = () => {
  const { characterName, characterRace, characterClass, characterAttributes } = useCharacterCreation();
  const navigate = useNavigate();

  const handleConfirm = async () => {
    try {
      const characterData = {
        name: characterName,
        race: characterRace,
        character_class: characterClass,
        attributes: {
          strength: characterAttributes[0],
          dexterity: characterAttributes[1],
          constitution: characterAttributes[2],
          intelligence: characterAttributes[3],
          wisdom: characterAttributes[4],
          charisma: characterAttributes[5],
          luck: characterAttributes[6],
          speed: characterAttributes[7]
        }
      };
      const response = await createCharacter(characterData);
      if (response) {
        navigate(`/game/${response.id}`);
      }
    } catch (error) {
      console.error("Failed to create character", error);
    }
  };

  return (
    <div>
      <h1>Character Summary</h1>
      <p>Name: {characterName}</p>
      <p>Race: {characterRace}</p>
      <p>Class: {characterClass}</p>
      <p>Attributes:</p>
      <ul>
        <li>Strength: {characterAttributes[0]}</li>
        <li>Dexterity: {characterAttributes[1]}</li>
        <li>Constitution: {characterAttributes[2]}</li>
        <li>Intelligence: {characterAttributes[3]}</li>
        <li>Wisdom: {characterAttributes[4]}</li>
        <li>Charisma: {characterAttributes[5]}</li>
        <li>Luck: {characterAttributes[6]}</li>
        <li>Speed: {characterAttributes[7]}</li>
      </ul>
      <button onClick={handleConfirm}>Confirm and Start Game</button>
    </div>
  );
};

export default CharacterSummary;
