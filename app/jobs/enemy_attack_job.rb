class EnemyAttackJob < ApplicationJob
  queue_as :default

  def perform(enemy_id, character_id)
    enemy = Enemy.find(enemy_id)
    character = Character.find(character_id)

    # Logic to handle attack
    damage = enemy.attack_points
    character.receive_damage(damage)

    # Log the attack
    CombatLog.create!(
      character_id: character.id,
      enemy_id: enemy.id,
      log_entry: "#{enemy.name} attacked #{character.name} and dealt #{damage} damage.",
      combat_id: character.current_combat.id,
      attacker_type: "Enemy",
      attacker_id: enemy.id
    )

    # If the character is still alive, queue the next attack
    if character.alive?
      CharacterAttackJob.set(wait: 5.seconds).perform_later(character_id, enemy_id)
    end
  end
end
