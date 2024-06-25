import React, { createContext, useContext, useState, ReactNode } from 'react';

interface CharacterCreationContextType {
  characterName: string;
  setCharacterName: (name: string) => void;
  characterRace: string;
  setCharacterRace: (race: string) => void;
  characterClass: string;
  setCharacterClass: (characterClass: string) => void;
  characterAttributes: number[];
  setCharacterAttributes: (attributes: number[]) => void;
}

const CharacterCreationContext = createContext<CharacterCreationContextType | undefined>(undefined);

export const CharacterCreationProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [characterName, setCharacterName] = useState<string>('');
  const [characterRace, setCharacterRace] = useState<string>('');
  const [characterClass, setCharacterClass] = useState<string>('');
  const [characterAttributes, setCharacterAttributes] = useState<number[]>([]);

  return (
    <CharacterCreationContext.Provider
      value={{
        characterName,
        setCharacterName,
        characterRace,
        setCharacterRace,
        characterClass,
        setCharacterClass,
        characterAttributes,
        setCharacterAttributes
      }}
    >
      {children}
    </CharacterCreationContext.Provider>
  );
};

export const useCharacterCreation = (): CharacterCreationContextType => {
  const context = useContext(CharacterCreationContext);
  if (!context) {
    throw new Error('useCharacterCreation must be used within a CharacterCreationProvider');
  }
  return context;
};
