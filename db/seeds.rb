# Clear existing data
CombatLog.destroy_all
CombatParticipant.destroy_all
Combat.destroy_all
Npc.destroy_all
Item.destroy_all
Enemy.destroy_all
CharacterSkill.destroy_all
Skill.destroy_all
Character.destroy_all
Room.destroy_all
CharacterAbility.destroy_all
Ability.destroy_all

# Create Skills
skills = ["Unarmed Combat", "One-Handed Weapon", "Two-Handed Weapon", "Ranged Weapon", "Flying", "Driving", "Healing", "Hacking", "Weapon Crafting", "Armor Crafting", "Item Crafting"]
skills.each { |skill| Skill.create!(name: skill) }

# Create Abilities
abilities = [
  { name: "Human Perseverance", description: "Increases luck and charisma by 2 for 10 minutes." },
  { name: "Soldier's Strike", description: "Deals a powerful strike with a chance to stun the enemy." },
  { name: "Elf Vision", description: "Increases intelligence and wisdom by 2 for 10 minutes." },
  { name: "Mage's Fireball", description: "Casts a fireball that deals damage over time." },
  { name: "Human Resilience", description: "Increases constitution by 3 for 5 minutes." },
  { name: "Soldier's Shield Bash", description: "Bashes the enemy with a shield, reducing their defense." },
  { name: "Elf Agility", description: "Increases dexterity and speed by 2 for 10 minutes." },
  { name: "Mage's Ice Blast", description: "Casts an ice blast that slows the enemy." }
]
abilities.each { |ability| Ability.create!(ability) }

# Create Rooms
starting_room = Room.create!(name: "Starting Room", description: "You are in the starting room.")
north_room = Room.create!(name: "North Room", description: "You are in the north room.")
south_room = Room.create!(name: "South Room", description: "You are in the south room.")
east_room = Room.create!(name: "East Room", description: "You are in the east room.")
west_room = Room.create!(name: "West Room", description: "You are in the west room.")

# Connect Rooms
starting_room.update!(north: north_room, south: south_room, east: east_room, west: west_room)
north_room.update!(south: starting_room)
south_room.update!(north: starting_room)
east_room.update!(west: starting_room)
west_room.update!(east: starting_room)

# Weapons
Item.create!(name: "Sword", slot: "hand", item_type: :weapon, damage: 10, effect: "None", rarity: "common", room: starting_room, description: "A basic sword.")
Item.create!(name: "Fire Axe", slot: "hand", item_type: :weapon, damage: 15, effect: "Burn", rarity: "rare", room: north_room, description: "An axe with fire damage.")

# Armor
Item.create!(name: "Leather Armor", slot: "body", item_type: :armor, defense: 5, rarity: "common", room: south_room, description: "Basic leather armor.")
Item.create!(name: "Dragon Scale Armor", slot: "body", item_type: :armor, defense: 20, rarity: "legendary", room: east_room, description: "Armor made from dragon scales.")

# Usable Items
Item.create!(name: "Health Potion", slot: "none", item_type: :usable, effect_description: "Restores 50 health", rarity: "common", room: west_room, description: "A potion that heals 50 health points.")

# Mounts
Item.create!(name: "War Horse", slot: "mount", item_type: :mount, speed_bonus: 10, rarity: "rare", room: starting_room, description: "A strong war horse.")

# Vehicles
Item.create!(name: "Space Cruiser", slot: "vehicle", item_type: :vehicle, speed_bonus: 20, rarity: "legendary", room: starting_room, description: "A fast space cruiser.")

# Create enemies with valid numeric values for health and attack points
enemy1 = Enemy.create!(name: "Goblin", description: "A nasty goblin.", room: west_room, health: 30, attack_points: 5)
enemy2 = Enemy.create!(name: "Orc", description: "A fierce orc.", room: east_room, health: 50, attack_points: 10)

# Create NPCs
npc1 = Npc.create!(name: "Merchant", room: south_room)
npc2 = Npc.create!(name: "Guard", room: north_room)

puts "Seed data generated successfully!"
