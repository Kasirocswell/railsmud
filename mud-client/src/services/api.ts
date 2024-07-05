const API_URL = "http://localhost:3000";

export const fetchCharacters = async () => {
  const response = await fetch(`${API_URL}/characters`);
  if (!response.ok) {
    throw new Error("Failed to fetch characters");
  }
  return response.json();
};

export const fetchCharacter = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}`);
  if (!response.ok) {
    throw new Error("Failed to fetch character data");
  }
  return response.json();
};

export const createCharacter = async (characterData: any) => {
  const response = await fetch(`${API_URL}/characters`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(characterData),
  });
  if (!response.ok) {
    const errorText = await response.text();
    console.error("Failed to create character:", errorText);
    throw new Error("Failed to create character");
  }
  return response.json();
};

export const deleteCharacter = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}`, {
    method: "DELETE",
  });
  if (!response.ok) {
    throw new Error("Failed to delete character");
  }
};

export const moveCharacter = async (characterId: number, direction: string) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/move/${direction}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to move character");
  }
  return response.json();
};

export const attackEnemy = async (characterId: number, enemyId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/attack/${enemyId}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Failed to initiate combat:", errorText);
    throw new Error("Failed to initiate combat");
  }

  return response.json();
};


export const activateAbility = async (characterId: number, abilityId: number, targetId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/activate_ability/${abilityId}/target_enemy/${targetId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to use ability");
  }
  return response.json();
};

export const lookAround = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/look`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to look around");
  }
  return response.json();
};

export const pickUpItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/pick_up/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to pick up item");
  }
  return response.json();
};

export const dropItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/drop/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to drop item");
  }
  return response.json();
};

export const equipItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/equip_item/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to equip item");
  }
  return response.json();
};

export const unequipItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/unequip_item/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to unequip item");
  }
  return response.json();
};

export const consumeItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/use/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to use item");
  }
  return response.json();
};

export const fetchInventory = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/inventory`);
  if (!response.ok) {
    throw new Error("Failed to fetch inventory");
  }
  return response.json();
};

export const examineItem = async (characterId: number, itemId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/examine/${itemId}`, {
    method: "POST",
  });
  if (!response.ok) {
    throw new Error("Failed to examine item");
  }
  return response.json();
};

export const fetchSkills = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/skills`);
  if (!response.ok) {
    throw new Error("Failed to fetch skills");
  }
  return response.json();
};


export const fetchCombatLogs = async (characterId: number) => {
  const response = await fetch(`${API_URL}/characters/${characterId}/combat_logs`);
  if (!response.ok) {
    throw new Error("Failed to fetch combat logs");
  }
  return response.json();
};


