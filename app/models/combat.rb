class Combat < ApplicationRecord
  has_many :combat_participants
  has_many :combat_logs
  belongs_to :enemy

  PENDING = 0
  ONGOING = 1
  COMPLETED = 2

  def start_combat
    Rails.logger.debug { "Starting combat: #{id}" }
    update_status = update(status: ONGOING)
    Rails.logger.debug { "Combat status after start: #{status}, Update successful: #{update_status}" }
  end

  def add_participant(participant)
    Rails.logger.debug { "Adding participant: #{participant.name} to combat: #{id}" }
    combat_participants.find_or_create_by(participant: participant)
  end

  def perform_attack(attacker, defender)
    Rails.logger.debug { "Performing attack: #{attacker.name} -> #{defender.name}" }
    damage = calculate_damage(attacker, defender)
    defender.update(health: defender.health - damage)

    log_entry = "#{attacker.name} attacked #{defender.name} for #{damage} damage. #{defender.name} has #{defender.health} health left."
    Rails.logger.debug { "Creating combat log: #{log_entry}" }

    combat_log = combat_logs.create(
      character_id: attacker.is_a?(Character) ? attacker.id : nil,
      enemy_id: defender.is_a?(Enemy) ? defender.id : nil,
      log_entry: log_entry,
      attacker_type: attacker.class.name,
      attacker_id: attacker.id
    )

    if combat_log.persisted?
      Rails.logger.debug { "Combat log created successfully: #{combat_log.log_entry}" }
    else
      Rails.logger.debug { "Failed to create combat log: #{combat_log.errors.full_messages.join(', ')}" }
    end

    if defender.health <= 0
      log_entry = "#{defender.name} has been defeated."
      Rails.logger.debug { "Creating combat log: #{log_entry}" }

      combat_log = combat_logs.create(
        character_id: attacker.is_a?(Character) ? attacker.id : nil,
        enemy_id: defender.is_a?(Enemy) ? defender.id : nil,
        log_entry: log_entry,
        attacker_type: attacker.class.name,
        attacker_id: attacker.id
      )

      if combat_log.persisted?
        Rails.logger.debug { "Combat log created successfully: #{combat_log.log_entry}" }
      else
        Rails.logger.debug { "Failed to create combat log: #{combat_log.errors.full_messages.join(', ')}" }
      end

      update(status: COMPLETED)
    end
  end

  def execute_combat
    Rails.logger.debug { "Executing combat: #{id}" }
    participants = combat_participants.to_a.cycle

    while status == ONGOING
      attacker = participants.next.participant
      defender = participants.next.participant

      Rails.logger.debug { "Attacker: #{attacker.name}, Defender: #{defender.name}" }

      perform_attack(attacker, defender)
      break if status == COMPLETED
    end

    Rails.logger.debug { "Combat executed. Log entries: #{combat_logs.pluck(:log_entry).join(', ')}" }
    true
  end

  def ongoing?
    status == ONGOING
  end

  private

  def calculate_damage(attacker, defender)
    attacker_attack = attacker.total_attack
    defender_defense = defender.respond_to?(:total_defense) ? defender.total_defense : (defender.defense || 0)
    [attacker_attack - defender_defense, 0].max
  end
end
