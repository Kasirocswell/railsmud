class Enemy < ApplicationRecord
  belongs_to :room
  has_many :combat_participants, as: :participant, dependent: :destroy
  has_many :combats, through: :combat_participants
  has_many :combat_logs

  validates :name, presence: true
  validates :health, numericality: { only_integer: true }
  validates :attack_points, numericality: { only_integer: true }
  validates :defense, numericality: { only_integer: true, allow_nil: true }
  validates :aggression_level, numericality: { only_integer: true, in: 0..10 }

  after_create :schedule_aggression_check

  def attack(target)
    damage = calculate_damage
    target.receive_damage(damage, self)
    CombatLog.create(character: target, enemy: self, combat: current_combat, log_entry: "#{name} attacked #{target.name} and dealt #{damage} damage.", attacker: self)
  end

  def attack_speed
    base_speed = 5 # base speed in seconds
    speed_modifier = [1 - (speed.to_f / 100), 0.1].max # Ensure a minimum attack speed
    base_speed * speed_modifier
  end

  def total_defense
    base_defense = 10 # Example base defense value
    base_defense + (self.defense || 0)
  end

  def receive_damage(amount, attacker)
    self.health -= amount
    if self.health <= 0
      self.health = 0
      log_entry = "#{name} has been defeated."
    else
      log_entry = "#{name} received #{amount} damage. Health: #{health}."
    end
    save
    CombatLog.create(character_id: attacker.id, enemy: self, combat: current_combat, log_entry: log_entry, attacker: attacker)
    log_entry
  end

  def die
    CombatLog.create(enemy: self, combat: current_combat, log_entry: "#{name} has been defeated.")
    update!(alive: false)
  end

  def calculate_damage_against(character)
    attack_power = attack_points
    defense_power = character.total_defense
    damage = attack_power - defense_power
    damage > 0 ? damage : 0
  end

  def alive?
    health > 0
  end

  def current_combat
    combats.where(status: :ongoing).last
  end

  private

  def calculate_damage
    attack_points + rand(1..5)
  end

  def schedule_aggression_check
    return if aggression_level.zero?

    wait_time = 11 - aggression_level
    EnemyAggressionJob.perform_in(wait_time.seconds, id)
  end
end
