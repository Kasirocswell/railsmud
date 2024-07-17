class Combat < ApplicationRecord
  has_many :combat_participants
  has_many :combat_logs
  belongs_to :enemy

  PENDING = 0
  ONGOING = 1
  COMPLETED = 2

  def start_combat
    Rails.logger.debug { "Starting combat: #{id}" }
    update(status: ONGOING)

    character = combat_participants.find_by(participant_type: 'Character').participant
    log_entry = "#{character.name} raises their weapon, ready for combat with #{enemy.name}."
    create_and_broadcast_log(character, enemy, log_entry)

    Rails.logger.debug { "Combat status after start: #{status}" }
    participants.each { |participant| participant.update(combat_state: true) }

    schedule_next_attacks
  end

  def add_participant(participant)
    Rails.logger.debug { "Adding participant: #{participant.name} to combat: #{id}" }
    combat_participants.find_or_create_by(participant: participant)
    participant.update(combat_state: true)
  end

  def perform_attack(attacker, defender)
    return unless attacker && defender
    return unless attacker.health > 0 && defender.health > 0

    Rails.logger.debug { "Performing attack: #{attacker.name} -> #{defender.name}" }

    damage = calculate_damage(attacker, defender)
    defender.update(health: defender.health - damage)

    if defender.health <= 0
      handle_defeat(attacker, defender)
    else
      log_entry = "#{attacker.name} attacked #{defender.name} for #{damage} damage. #{defender.name} has #{[defender.health, 0].max} health left."
      create_and_broadcast_log(attacker, defender, log_entry)
      defender.update(combat_state: true)
      schedule_next_attack(defender)
    end
  end

  def create_and_broadcast_log(attacker, defender, log_entry)
    Rails.logger.debug { "Creating combat log. Attacker: #{attacker&.id}, Defender: #{defender&.id}, Log: #{log_entry}" }

    # Check for existing similar log to avoid duplicates
    existing_log = combat_logs.find_by(
      character_id: attacker.is_a?(Character) ? attacker.id : defender.is_a?(Character) ? defender.id : nil,
      enemy_id: attacker.is_a?(Enemy) ? attacker.id : defender.is_a?(Enemy) ? defender.id : nil,
      log_entry: log_entry
    )

    return if existing_log.present?

    character_id = attacker.is_a?(Character) ? attacker.id : defender.is_a?(Character) ? defender.id : nil
    enemy_id = attacker.is_a?(Enemy) ? attacker.id : defender.is_a?(Enemy) ? defender.id : nil

    Rails.logger.debug { "Character ID: #{character_id}, Enemy ID: #{enemy_id}" }

    combat_log = combat_logs.create(
      character_id: character_id,
      enemy_id: enemy_id,
      log_entry: log_entry,
      attacker_type: attacker&.class&.name,
      attacker_id: attacker&.id
    )

    if combat_log.persisted?
      ActionCable.server.broadcast "combat_log_#{combat_log.character_id || combat_log.enemy_id}", combat_log
      Rails.logger.debug { "Broadcasting log: #{combat_log.log_entry}" }
    else
      Rails.logger.debug { "Failed to create combat log: #{combat_log.errors.full_messages.join(', ')}" }
    end
  end

  def handle_defeat(attacker, defender)
    log_entry = "#{defender.name} has been defeated."
    create_and_broadcast_log(attacker, defender, log_entry)
  
    create_corpse(defender)
  
    update(status: COMPLETED) if participants.all? { |p| !p.alive? }
  
    participants.each { |participant| participant.update(combat_state: false) }
  end
  
  def create_corpse(defender)
    room = defender.room
    corpse = Corpse.create!(
      room: room,
      character: defender.is_a?(Character) ? defender : nil,
      enemy: defender.is_a?(Enemy) ? defender : nil,
      loot: defender.inventory.items # assuming `items` is a method that returns the items array
    )
    defender.inventory.clear_items # assuming `clear_items` clears the inventory
    Rails.logger.debug { "Created corpse: #{corpse.id} in room: #{room.id} with loot: #{corpse.loot}" }
  end

  def schedule_next_attacks
    Rails.logger.debug { "Scheduling next attacks for combat: #{id}" }
    combat_participants.each do |cp|
      schedule_next_attack(cp.participant)
    end
  end

  def schedule_next_attack(participant)
    return unless participant.combat_state && ongoing?

    attack_interval = calculate_attack_interval(participant)
    Rails.logger.debug { "Scheduling next attack for participant: #{participant.id} with interval: #{attack_interval}" }
    CombatAttackJob.set(wait: attack_interval.seconds).perform_later(self.id, participant.id)
  end

  def ongoing?
    status == ONGOING
  end

  def calculate_attack_interval(participant)
    speed = participant.speed || 10 # default speed if not set
    20.0 / speed # Adjusted interval for attacks
  end

  def calculate_damage(attacker, defender)
    attacker_attack = attacker.is_a?(Character) ? attacker.total_attack : attacker.attack_points
    defender_defense = defender.respond_to?(:total_defense) ? defender.total_defense : (defender.defense || 0)
    [attacker_attack - defender_defense, 0].max
  end

  private

  def participants
    combat_participants.map(&:participant)
  end
end
