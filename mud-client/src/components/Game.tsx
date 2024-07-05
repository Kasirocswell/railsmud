import React, { useState, useEffect, useRef } from 'react';
import { createConsumer } from '@rails/actioncable';
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
import { CombatResponse, CombatLog } from '../interfaces/CombatResponse';

interface Character {
  id: number;
  name: string;
  race: string;
  character_class: string;
  health: number;
  action_points: number;
  total_attack: number;
  total_defense: number;
  abilities: any[];
  current_room: any;
  inventory: any;
}

const Game: React.FC = () => {
  const { characterId } = useParams<{ characterId: string }>();
  const [character, setCharacter] = useState<Character | null>(null);
  const [gameLog, setGameLog] = useState<{ id: string, log_entry: string }[]>([]);
  const [command, setCommand] = useState<string>('');
  const gameLogEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const getCharacter = async () => {
      if (characterId) {
        try {
          const data = await fetchCharacter(Number(characterId));
          console.log('Fetched character data:', data);
          setCharacter(data);
          await fetchAndSetCombatLogs(Number(characterId));
        } catch (error) {
          console.error('Failed to fetch character data', error);
        }
      }
    };
    getCharacter();
  
    const consumer = createConsumer('ws://localhost:3000/cable');
    const subscription = consumer.subscriptions.create(
      { channel: 'CombatLogChannel', character_id: characterId },
      {
        connected() {
          console.log('Connected to CombatLogChannel');
        },
        disconnected() {
          console.log('Disconnected from CombatLogChannel');
        },
        received(data) {
          console.log('Received new log entry:', data);
  
          try {
            // Manually extract the content within the <template> tag
            const templateStart = data.indexOf('<template>') + '<template>'.length;
            const templateEnd = data.indexOf('</template>');
            const templateContent = data.slice(templateStart, templateEnd).trim();
  
            // Now parse the extracted content
            const parser = new DOMParser();
            const doc = parser.parseFromString(templateContent, 'text/html');
            const logEntryElement = doc.querySelector('div');
            const logEntry = logEntryElement ? logEntryElement.textContent?.trim() : null;
  
            console.log('LOG ENTRY', logEntry);
  
            if (logEntry) {
              setGameLog((prevLog) => {
                const updatedLog = [
                  ...prevLog,
                  { id: `${character?.id}-${Date.now()}-${logEntry}`, log_entry: logEntry },
                ];
                console.log('Updated game log:', updatedLog);
                return updatedLog;
              });
              scrollToBottom();
            } else {
              console.warn('Log entry is empty or null:', logEntry);
            }
          } catch (error) {
            console.error('Error parsing log entry:', error);
          }
        },
      }
    );
  
    return () => {
      subscription.unsubscribe();
    };
  }, [characterId]);
  
  

  const fetchAndSetCombatLogs = async (characterId: number) => {
    try {
      const logs = await fetchCombatLogs(characterId);
      console.log("Fetched combat logs:", logs); // Log fetched combat logs
      const logMessages = logs.map((log: any, index: number) => ({
        id: `${characterId}-${log.created_at}-${log.log_entry}-${index}`,
        log_entry: log.log_entry
      }));
      setGameLog(logMessages);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to fetch combat logs", error);
    }
  };

  const handleMove = async (direction: string) => {
    if (!character) return;

    try {
      const result = await moveCharacter(Number(characterId), direction);
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
      setCharacter(result.character);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to move character:", error);
    }
  };

  const handleAbilityUse = async (abilityId: number, enemyId: number) => {
    if (!character) return;

    try {
      const result = await activateAbility(Number(characterId), abilityId, enemyId);
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
      setCharacter(result.character);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to use ability:", error);
    }
  };

  const handleLook = async () => {
    if (!character) return;

    try {
      const result = await lookAround(Number(characterId));
      const directions = Object.keys(result.directions).filter(dir => result.directions[dir]).join(', ');
      const enemies = result.enemies.length > 0 ? `Enemies: ${result.enemies.join(', ')}` : 'No enemies present.';
      const loot = result.loot.length > 0 ? `Loot: ${result.loot.join(', ')}` : 'No loot present.';
      const logMessage = `You look around and see: ${result.room_description}. ${enemies} ${loot} Available directions: ${directions}.`;
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${logMessage}`, log_entry: logMessage }]);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to look around:", error);
    }
  };

  const handlePickUp = async (itemName: string) => {
    if (!character) return;

    try {
      const item = character.current_room.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await pickUpItem(Number(characterId), item.id);
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
        setCharacter(result.character);
        scrollToBottom();
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No item named "${itemName}" found in the room`, log_entry: `No item named "${itemName}" found in the room` }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to pick up item:", error);
    }
  };

  const handleDrop = async (itemName: string) => {
    if (!character) return;

    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await dropItem(Number(characterId), item.id);
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
        setCharacter(result.character);
        await handleLook(); // Refresh room data after dropping an item
        scrollToBottom();
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No item named "${itemName}" found in your inventory`, log_entry: `No item named "${itemName}" found in your inventory` }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to drop item:", error);
    }
  };

  const handleEquip = async (itemName: string) => {
    if (!character) return;

    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        const result = await equipItem(Number(characterId), item.id);
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
        setCharacter(result.character);
        scrollToBottom();
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No item named "${itemName}" found in your inventory`, log_entry: `No item named "${itemName}" found in your inventory` }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to equip item:", error);
    }
  };

  const handleUnequip = async (itemName: string) => {
    if (!character) return;

    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item && item.equipped) {
        const result = await unequipItem(Number(characterId), item.id);
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
        setCharacter(result.character);
        scrollToBottom();
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No equipped item named "${itemName}" found`, log_entry: `No equipped item named "${itemName}" found` }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to unequip item:", error);
    }
  };

  const handleShowInventory = async () => {
    if (!character) return;

    try {
      const result = await fetchInventory(Number(characterId));
      const equippedItems = result.equipped_items.length > 0 ? `Equipped: ${result.equipped_items.map((item: any) => item.name).join(', ')}` : 'No items equipped.';
      const inventoryItems = result.inventory_items.length > 0 ? `Inventory: ${result.inventory_items.map((item: any) => item.name).join(', ')}` : 'No items in inventory.';
      const logMessage = `Your inventory: ${equippedItems} ${inventoryItems}`;
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${logMessage}`, log_entry: logMessage }]);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to fetch inventory:", error);
    }
  };

  const handleSay = (message: string) => {
    if (!character) return;

    if (message) {
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${character.name} says: "${message}"`, log_entry: `${character.name} says: "${message}"` }]);
      scrollToBottom();
    }
  };

  const handleUse = async (itemName: string) => {
    if (!character) return;

    try {
      const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
      if (item) {
        if (item.item_type === 'usable') {
          const result = await consumeItem(Number(characterId), item.id);
          setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
          setCharacter(result.character);
          scrollToBottom();
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-The item "${itemName}" is not usable`, log_entry: `The item "${itemName}" is not usable` }]);
          scrollToBottom();
        }
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No item named "${itemName}" found in your inventory`, log_entry: `No item named "${itemName}" found in your inventory` }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to use item:", error);
    }
  };

  const handleExamine = async (itemName: string) => {
    if (!character) return;

    try {
      if (character?.inventory?.items) {
        const item = character.inventory.items.find((i: any) => i.name.toLowerCase() === itemName.toLowerCase());
        if (item) {
          const result = await examineItem(Number(characterId), item.id);
          setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${result.message}`, log_entry: result.message }]);
          scrollToBottom();
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-No item named "${itemName}" found in your inventory`, log_entry: `No item named "${itemName}" found in your inventory` }]);
          scrollToBottom();
        }
      } else {
        setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-Inventory is not available`, log_entry: 'Inventory is not available' }]);
        scrollToBottom();
      }
    } catch (error) {
      console.error("Failed to examine item:", error);
    }
  };

  const handleListSkills = async () => {
    if (!character) return;

    try {
      const result = await fetchSkills(Number(characterId));
      const skills = result.skills.map((skill: any, index: number) => `${skill.name}: Level ${skill.level}`).join(', ');
      const logMessage = `Your skills: ${skills}`;
      setGameLog(prevLog => [...prevLog, { id: `${character.id}-${Date.now()}-${logMessage}`, log_entry: logMessage }]);
      scrollToBottom();
    } catch (error) {
      console.error("Failed to fetch skills:", error);
    }
  };

  const handleAttack = async (enemyId: number) => {
    if (!character) {
      console.error("Character data is not available.");
      setGameLog((prevLog) => [
        ...prevLog,
        { id: `${Date.now()}-No character data`, log_entry: 'No character data available' },
      ]);
      scrollToBottom();
      return;
    }

    try {
      const result: CombatResponse = await attackEnemy(character.id, enemyId);

      // Ensure result is an object with a combat_logs array
      if (result.combat_logs && Array.isArray(result.combat_logs)) {
        setGameLog((prevLog) => [
          ...prevLog,
          ...result.combat_logs.map((log: CombatLog, index: number) => ({
            id: `${character.id}-${Date.now()}-${log.log_entry}-${index}`,
            log_entry: log.log_entry,
          })),
        ]);
      } else {
        console.error("Unexpected response structure:", result);
        setGameLog((prevLog) => [
          ...prevLog,
          { id: `${character.id}-${Date.now()}-Unexpected response structure`, log_entry: 'Unexpected response structure' },
        ]);
      }

      scrollToBottom();
    } catch (error) {
      console.error("Failed to initiate combat:", error);
      setGameLog((prevLog) => [
        ...prevLog,
        { id: `${character.id}-${Date.now()}-Failed to initiate combat`, log_entry: 'Failed to initiate combat' },
      ]);
      scrollToBottom();
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
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid direction for move command`, log_entry: 'Invalid direction for move command' }]);
          scrollToBottom();
        }
        break;
      case 'look':
        if (target === null) {
          handleLook();
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Look command does not require a target`, log_entry: 'Look command does not require a target' }]);
          scrollToBottom();
        }
        break;
      case 'attack':
        if (!isNaN(Number(target))) {
          handleAttack(Number(target));
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for attack command`, log_entry: 'Invalid target for attack command' }]);
          scrollToBottom();
        }
        break;
      case 'use':
        if (typeof target === 'string') {
          handleUse(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for use command`, log_entry: 'Invalid target for use command' }]);
          scrollToBottom();
        }
        break;
      case 'pickup':
        if (typeof target === 'string') {
          handlePickUp(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for pickup command`, log_entry: 'Invalid target for pickup command' }]);
          scrollToBottom();
        }
        break;
      case 'drop':
        if (typeof target === 'string') {
          handleDrop(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for drop command`, log_entry: 'Invalid target for drop command' }]);
          scrollToBottom();
        }
        break;
      case 'equip':
        if (typeof target === 'string') {
          handleEquip(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for equip command`, log_entry: 'Invalid target for equip command' }]);
          scrollToBottom();
        }
        break;
      case 'unequip':
        if (typeof target === 'string') {
          handleUnequip(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for unequip command`, log_entry: 'Invalid target for unequip command' }]);
          scrollToBottom();
        }
        break;
      case 'inventory':
        if (target === null) {
          handleShowInventory();
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Inventory command does not require a target`, log_entry: 'Inventory command does not require a target' }]);
          scrollToBottom();
        }
        break;
      case 'examine':
        if (typeof target === 'string') {
          handleExamine(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Invalid target for examine command`, log_entry: 'Invalid target for examine command' }]);
          scrollToBottom();
        }
        break;
      case 'skills':
        if (target === null) {
          handleListSkills();
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Skills command does not require a target`, log_entry: 'Skills command does not require a target' }]);
          scrollToBottom();
        }
        break;
      case 'say':
        if (typeof target === 'string') {
          handleSay(target);
        } else {
          setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Say command requires a message`, log_entry: 'Say command requires a message' }]);
          scrollToBottom();
        }
        break;
      default:
        setGameLog(prevLog => [...prevLog, { id: `${character?.id}-${Date.now()}-Unknown command`, log_entry: 'Unknown command' }]);
        scrollToBottom();
    }

    setCommand('');
  };

  const scrollToBottom = () => {
    gameLogEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

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
          {character.current_room && character.current_room.enemies && Array.isArray(character.current_room.enemies) && character.current_room.enemies.map((enemy: any, index: number) => (
            <button key={`${enemy.id}-${index}`} onClick={() => handleAttack(enemy.id)}>
              Attack {enemy.name}
            </button>
          ))}
          <h3>Abilities</h3>
          {character.abilities && Array.isArray(character.abilities) && character.abilities.map((ability: any, index: number) => (
            <div key={`${ability.id}-${index}`}>
              <h4>{ability.name}</h4>
              {character.current_room && character.current_room.enemies && Array.isArray(character.current_room.enemies) && character.current_room.enemies.map((enemy: any, enemyIndex: number) => (
                <button key={`${ability.id}-${enemy.id}-${enemyIndex}`} onClick={() => handleAbilityUse(ability.id, enemy.id)}>
                  Use {ability.name} on {enemy.name}
                </button>
              ))}
            </div>
          ))}
          <h3>Inventory</h3>
          <ul>
            {character.inventory && character.inventory.items && Array.isArray(character.inventory.items) && character.inventory.items.map((item: any, index: number) => (
              <li key={`${item.id}-${index}`}>
                {item.name}: {item.description}
                <button onClick={() => handleEquip(item.name)}>Equip</button>
                <button onClick={() => handleDrop(item.name)}>Drop</button>
              </li>
            ))}
          </ul>
          <h3>Room Loot</h3>
          <ul>
            {character.current_room && character.current_room.items && Array.isArray(character.current_room.items) && character.current_room.items.map((item: any, index: number) => (
              <li key={`${item.id}-${index}`}>
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
          <p key={`${log.id}-${index}`}>{log.log_entry}</p>
        ))}
        <div ref={gameLogEndRef} />
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
