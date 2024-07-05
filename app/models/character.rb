class Character < ApplicationRecord
  belongs_to :current_room, class_name: 'Room', optional: true
  has_one :inventory, dependent: :destroy
  has_many :character_abilities, dependent: :destroy
  has_many :abilities, through: :character_abilities
  has_many :character_skills, dependent: :destroy
  has_many :skills, through: :character_skills
  has_many :combat_participants, as: :participant, dependent: :destroy
  has_many :combats, through: :combat_participants
  has_many :combat_logs

  before_create :initialize_attributes
  after_create :create_inventory, :assign_starting_skills, :assign_starting_abilities

  def move(direction)
    new_room = case direction
               when 'north'
                 current_room.north
               when 'south'
                 current_room.south
               when 'east'
                 current_room.east
               when 'west'
                 current_room.west
               end

    if new_room
      update(current_room: new_room)
      "You moved #{direction} to #{new_room.name}."
    else
      "You can't move #{direction} from here."
    end
  end

  def inventory_list
    inventory.items.map(&:name).join(', ')
  end

  def pick_up(item)
    if current_room.items.include?(item)
      item.update(room: nil, inventory: inventory)
      "You picked up the #{item.name}."
    else
      "The item is not in this room."
    end
  end

  def drop(item)
    if inventory.items.include?(item)
      item.update(room: current_room, inventory: nil)
      "You dropped the #{item.name}."
    else
      "You don't have that item."
    end
  end

  def equip_item(item)
    inventory.equip(item)
    "You equipped the #{item.name}."
  end

  def unequip_item(item)
    inventory.unequip(item)
    "You unequipped the #{item.name}."
  end

  def total_attack
    weapon_attack = inventory&.items&.where(equipped: true, item_type: 'weapon')&.sum(:damage) || 0
    strength + weapon_attack
  end

  def total_defense
    base_defense = 10 # Example base defense value
    base_defense + constitution
  end

  def initiate_attack(enemy)
    combat = Combat.start_combat(self, enemy)
    combat.add_participant(self)
    combat
  end

  def attack(target)
    return unless target.alive? # Ensure the target is alive
  
    damage = calculate_damage_against(target)
    target.receive_damage(damage, self)
    log_entry = "#{name} attacked #{target.name} and dealt #{damage} damage."
  
    # Create a combat log
    CombatLog.create(character: self, enemy: target, combat: current_combat, log_entry: log_entry, attacker: self)
  
    # Check if the target is defeated
    if target.health <= 0
      target.die
      CombatLog.create(character: self, enemy: target, combat: current_combat, log_entry: "#{target.name} has been defeated.", attacker: self)
    end
  end
  

  def receive_damage(amount, attacker)
    self.health -= amount
    log_entry = if self.health <= 0
                  self.health = 0
                  "#{name} has been defeated."
                else
                  "#{name} received #{amount} damage. Health: #{health}."
                end
    save
    CombatLog.create(character: self, attacker: attacker, combat: current_combat, log_entry: log_entry, enemy: attacker)
    log_entry
  end

  def die
    CombatLog.create(character: self, combat: current_combat, log_entry: "#{name} has been defeated.")
    update!(alive: false)
  end

  def attack_speed
    base_speed = 5 # base speed in seconds
    speed_modifier = [1 - (speed.to_f / 100), 0.1].max # Ensure a minimum attack speed
    base_speed * speed_modifier
  end

  def alive?
    health > 0
  end

  def calculate_damage_against(enemy)
    attack_power = total_attack
    defense_power = enemy.total_defense
    damage = attack_power - defense_power
    damage > 0 ? damage : 0
  end

  def as_json(options = {})
    super(options).merge({
      total_attack: total_attack,
      total_defense: total_defense,
      skills: character_skills.includes(:skill).map { |cs| { name: cs.skill.name, level: cs.level } },
      abilities: abilities.map { |ability| { name: ability.name, description: ability.description, level: ability.level } }
    })
  end

  private

  def initialize_attributes
    self.health ||= 100
    self.action_points ||= 100
    self.credits ||= 100
    self.xp ||= 0
    self.level ||= 1
    self.xp_until_next_level ||= level * 1000

    # Initialize attributes if they are not already set
    self.strength ||= 0
    self.dexterity ||= 0
    self.constitution ||= 0
    self.intelligence ||= 0
    self.wisdom ||= 0
    self.charisma ||= 0
    self.luck ||= 0
    self.speed ||= 0
  end

  def assign_starting_skills
    Skill.all.each do |skill|
      CharacterSkill.create!(character: self, skill: skill, level: 1)
    end
  end

  def assign_starting_abilities
    starting_abilities = {
      "Human" => [{ name: "Human Resilience", description: "Increase luck by 10 for a short period." }],
      "Soldier" => [{ name: "Power Strike", description: "A powerful attack that deals extra damage." }]
    }

    abilities_to_assign = (starting_abilities[race] || []) + (starting_abilities[character_class] || [])

    abilities_to_assign.each do |ability_data|
      ability = Ability.create!(name: ability_data[:name], description: ability_data[:description], level: 1)
      CharacterAbility.create!(character: self, ability: ability)
    end
  end

  def current_combat
    combats.find_by(status: 0)
  end
end
