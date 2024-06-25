import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { 
  fetchCharacter, 
  moveCharacter, 
  attackEnemy, 
  activateAbility, 
  lookAround, 
  pickUpItem, 
  dropItem, 
  equipItem, 
  unequipItem, 
  consumeItem,
  examineItem,
  fetchSkills,
  fetchInventory,
  fetchCombatLogs
} from '../services/api';

const Game: React.FC = () => {
  const { characterId } = useParams<{ characterId: string }>();
  const [character, setCharacter] = useState<any>(null);
  const [gameLog, setGameLog] = useState<string[]>([]);
  const [command, setCommand] = useState<string>('');

  useEffect(() => {
    const getCharacter = async () => {
      if (characterId) {
        try {
          const data = await fetchCharacter(Number(characterId));
          setCharacter(data);
        } catch (error) {
          console.error("Failed to fetch character data", error);
        }
      }
    };
    getCharacter();
  }, [characterId]);

  const fetchAndSetCombatLogs = async () => {
    try {
      const logs = await fetchCombatLogs(Number(characterId));
      setGameLog(logs.map((log: any) => log.log_entry));
    } catch (error) {
      console.error("Failed to fetch combat logs", error);
    }
  };

  

  const handleMove = async (direction: string) => {
    try {
      const result = await moveCharacter(Number(characterId), direction);
      console.log("Move result:", result);
      setGameLog(prevLog => [...prevLog, result.message]);
      setCharacter(result.character);
    } catch (error) {
      console.error("Failed to move character:", error);
    }
  };

  const handleAbilityUse = async (abilityId: number, enemyId: number) => {
    try {
      const result = await activateAbility(Number(characterId), abilityId, enemyId);
      console.log("Ability use result:", result);
      setGameLog(prevLog => [...prevLog, result.message]);
      setCharacter(result.character);
      await fetchAndSetCombatLogs();
    } catch (error) {
      console.error("Failed to use ability:", error);
    }
  };

  const handleLook = async () => {
    try {
      const result = await lookAround(Number(characterId));
      console.log("Look result:", result);
      const directions = Object.keys(result.directions).filter(dir => result.directions[dir]).join(', ');
      const enemies = result.enemies.length > 0 ? `Enemies: ${result.enemies.join(', ')}` : 'No enemies present.';
      const loot = result.loot.length > 0 ? `Loot: ${result.loot.join(', ')}` : 'No loot present.';
      const logMessage = `You look around and see: ${result.room_description}. ${enemies} ${loot} Available directions: ${directions}.`;
      setGameLog(prevLog => [...prevLog, logMessage]);
    } catch (error) {
      console.error("Failed to look around:", error);
    }
  };

  const handlePickUp = async (itemName: string) => {
    try {
      const item = character.current_room.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await pickUpItem(Number(characterId), item.id);
        console.log("Pick Up result:", result);
        setGameLog(prevLog => [...prevLog, result.message]);
        setCharacter(result.character);
      } else {
        setGameLog(prevLog => [...prevLog, `No item named "${itemName}" found in the room`]);
      }
    } catch (error) {
      console.error("Failed to pick up item:", error);
    }
  };

  const handleDrop = async (itemName: string) => {
    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await dropItem(Number(characterId), item.id);
        console.log("Drop result:", result);
        setGameLog(prevLog => [...prevLog, result.message]);
        setCharacter(result.character);
        await handleLook(); // Refresh room data after dropping an item
      } else {
        setGameLog(prevLog => [...prevLog, `No item named "${itemName}" found in your inventory`]);
      }
    } catch (error) {
      console.error("Failed to drop item:", error);
    }
  };

  const handleEquip = async (itemName: string) => {
    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await equipItem(Number(characterId), item.id);
        console.log("Equip result:", result);
        setGameLog(prevLog => [...prevLog, result.message]);
        setCharacter(result.character);
      } else {
        setGameLog(prevLog => [...prevLog, `No item named "${itemName}" found in your inventory`]);
      }
    } catch (error) {
      console.error("Failed to equip item:", error);
    }
  };

  const handleUnequip = async (itemName: string) => {
    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item && item.equipped) {
        const result = await unequipItem(Number(characterId), item.id);
        console.log("Unequip result:", result);
        setGameLog(prevLog => [...prevLog, result.message]);
        setCharacter(result.character);
      } else {
        setGameLog(prevLog => [...prevLog, `No equipped item named "${itemName}" found`]);
      }
    } catch (error) {
      console.error("Failed to unequip item:", error);
    }
  };

  const handleShowInventory = async () => {
    try {
      const result = await fetchInventory(Number(characterId));
      console.log("Inventory result:", result);
      const equippedItems = result.equipped_items.length > 0 ? `Equipped: ${result.equipped_items.map((item: any) => item.name).join(', ')}` : 'No items equipped.';
      const inventoryItems = result.inventory_items.length > 0 ? `Inventory: ${result.inventory_items.map((item: any) => item.name).join(', ')}` : 'No items in inventory.';
      const logMessage = `Your inventory: ${equippedItems} ${inventoryItems}`;
      setGameLog(prevLog => [...prevLog, logMessage]);
    } catch (error) {
      console.error("Failed to fetch inventory:", error);
    }
  };

  const handleSay = (message: string) => {
    if (message) {
      setGameLog(prevLog => [...prevLog, `${character.name} says: "${message}"`]);
    }
  };

  const handleUse = async (itemName: string) => {
    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        if (item.item_type === 'usable') {
          console.log(`Found usable item in inventory: ${item.name}, id: ${item.id}`);
          const result = await consumeItem(Number(characterId), item.id);
          console.log(`Result from consumeItem: ${result.message}`);
          setGameLog(prevLog => [...prevLog, result.message]);
          setCharacter(result.character); // assuming the API returns the updated character
        } else {
          console.log(`The item "${itemName}" is not usable`);
          setGameLog(prevLog => [...prevLog, `The item "${itemName}" is not usable`]);
        }
      } else {
        console.log(`No item named "${itemName}" found in your inventory`);
        setGameLog(prevLog => [...prevLog, `No item named "${itemName}" found in your inventory`]);
      }
    } catch (error) {
      console.error("Failed to use item:", error);
    }
  };

  const handleExamine = async (itemName: string) => {
    try {
      if (character?.inventory?.items) {
        const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
        if (item) {
          const result = await examineItem(Number(characterId), item.id);
          console.log(`Result from examineItem: ${result.message}`);
          setGameLog(prevLog => [...prevLog, result.message]);
        } else {
          console.log(`No item named "${itemName}" found in your inventory`);
          setGameLog(prevLog => [...prevLog, `No item named "${itemName}" found in your inventory`]);
        }
      } else {
        console.log('Inventory is not available');
        setGameLog(prevLog => [...prevLog, 'Inventory is not available']);
      }
    } catch (error) {
      console.error("Failed to examine item:", error);
    }
  };
  
  const handleListSkills = async () => {
    try {
      const result = await fetchSkills(Number(characterId));
      console.log("Skills result:", result);
      const skills = result.skills.map((skill: any) => `${skill.name}: Level ${skill.level}`).join(', ');
      const logMessage = `Your skills: ${skills}`;
      setGameLog(prevLog => [...prevLog, logMessage]);
    } catch (error) {
      console.error("Failed to fetch skills:", error);
    }
  };

  const handleAttack = async (enemyId: number) => {
    try {
      const result = await attackEnemy(character.id, enemyId);
      console.log("Combat initiated:", result);
      setGameLog((prevLog) => [...prevLog, result.log.log_entry]);
      setCharacter(result.combat); 
    } catch (error) {
      console.error("Failed to initiate combat:", error);
      setGameLog((prevLog) => [...prevLog, "Failed to initiate combat"]);
    }
  };
  

  const handleCommandSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    const parts = command.split(' ');
    const action = parts[0].toLowerCase();
    const target = parts[1] ? parts.slice(1).join(' ') : null;

    switch (action) {
      case 'move':
        if (typeof target === 'string') {
          handleMove(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid direction for move command']);
        }
        break;
      case 'look':
        if (target === null) {
          handleLook();
        } else {
          setGameLog(prevLog => [...prevLog, 'Look command does not require a target']);
        }
        break;
      case 'attack':
        if (typeof target === 'number') {
          handleAttack(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for attack command']);
        }
        break;
      case 'use':
        if (typeof target === 'string') {
          handleUse(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for use command']);
        }
        break;
      case 'pickup':
        if (typeof target === 'string') {
          handlePickUp(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for pickup command']);
        }
        break;
      case 'drop':
        if (typeof target === 'string') {
          handleDrop(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for drop command']);
        }
        break;
      case 'equip':
        if (typeof target === 'string') {
          handleEquip(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for equip command']);
        }
        break;
      case 'unequip':
        if (typeof target === 'string') {
          handleUnequip(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Invalid target for unequip command']);
        }
        break;
      case 'inventory':
        if (target === null) {
          handleShowInventory();
        } else {
          setGameLog(prevLog => [...prevLog, 'Inventory command does not require a target']);
        }
        break;
      case 'examine':
        if (typeof target === 'string') {
          handleExamine(target);
      } else {
        setGameLog(prevLog => [...prevLog, 'Invalid target for examine command']);
      }
      break;
      case 'skills':
        if (target === null) {
          handleListSkills();
        } else {
          setGameLog(prevLog => [...prevLog, 'Skills command does not require a target']);
        }
        break;
      case 'say':
        if (typeof target === 'string') {
          handleSay(target);
        } else {
          setGameLog(prevLog => [...prevLog, 'Say command requires a message']);
        }
        break;
      default:
        setGameLog(prevLog => [...prevLog, 'Unknown command']);
    }

    setCommand('');
  };

  useEffect(() => {
    const getCharacter = async () => {
      if (characterId) {
        try {
          const data = await fetchCharacter(Number(characterId));
          setCharacter(data);
        } catch (error) {
          console.error("Failed to fetch character data", error);
        }
      }
    };

    const getCombatLogs = async () => {
      if (characterId) {
        try {
          const logs = await fetchCombatLogs(Number(characterId));
          setGameLog(logs.map((log: any) => log.log_entry));
        } catch (error) {
          console.error("Failed to fetch combat logs", error);
        }
      }
    };

    getCharacter();
    getCombatLogs();
  }, [characterId]);

  return (
    <div>
      <h1>MUD Game</h1>
      {character ? (
        <div>
          <h2>{character.name}</h2>
          {character.current_room ? (
            <>
              <p>Current Room: {character.current_room.name}</p>
              <p>{character.current_room.description}</p>
            </>
          ) : (
            <p>No room information available.</p>
          )}
          <p>Health: {character.health}</p>
          <p>Action Points: {character.action_points}</p>
          <p>Total Attack: {character.total_attack}</p>
          <p>Total Defense: {character.total_defense}</p>
          <h3>Enemies</h3>
          {character.current_room && character.current_room.enemies && Array.isArray(character.current_room.enemies) && character.current_room.enemies.map((enemy: any) => (
            <button key={enemy.id} onClick={() => handleAttack(enemy.id)}>
              Attack {enemy.name}
            </button>
          ))}
          <h3>Abilities</h3>
          {character.abilities && Array.isArray(character.abilities) && character.abilities.map((ability: any) => (
            <div key={ability.id}>
              <h4>{ability.name}</h4>
              {character.current_room && character.current_room.enemies && Array.isArray(character.current_room.enemies) && character.current_room.enemies.map((enemy: any) => (
                <button key={enemy.id} onClick={() => handleAbilityUse(ability.id, enemy.id)}>
                  Use {ability.name} on {enemy.name}
                </button>
              ))}
            </div>
          ))}
          <h3>Inventory</h3>
          <ul>
            {character.inventory && character.inventory.items && Array.isArray(character.inventory.items) && character.inventory.items.map((item: any) => (
              <li key={item.id}>
                {item.name}: {item.description}
                <button onClick={() => handleEquip(item.name)}>Equip</button>
                <button onClick={() => handleDrop(item.name)}>Drop</button>
              </li>
            ))}
          </ul>
          <h3>Room Loot</h3>
          <ul>
            {character.current_room && character.current_room.items && Array.isArray(character.current_room.items) && character.current_room.items.map((item: any) => (
              <li key={item.id}>
                {item.name}: {item.description}
              </li>
            ))}
          </ul>
        </div>
      ) : (
        <p>Loading character...</p>
      )}
      <h3>Game Log</h3>
      <div style={{ border: '1px solid black', height: '300px', overflowY: 'scroll', padding: '10px' }}>
        {gameLog.map((log, index) => (
          <p key={index}>{log}</p>
        ))}
      </div>
      <form onSubmit={handleCommandSubmit}>
        <input 
          type="text" 
          value={command} 
          onChange={(e) => setCommand(e.target.value)} 
          placeholder="Enter command (e.g., 'move north')" 
          style={{ width: '100%', padding: '10px', marginTop: '10px' }}
        />
        <button type="submit" style={{ width: '100%', padding: '10px', marginTop: '5px' }}>Submit</button>
      </form>
    </div>
  );
};

export default Game;
