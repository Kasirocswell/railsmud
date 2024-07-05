class CharacterAttackJob < ApplicationJob
  queue_as :default

  def perform(character_id, enemy_id)
    character = Character.find(character_id)
    enemy = Enemy.find(enemy_id)

    # Logic to handle attack
    damage = character.attack_points
    enemy.receive_damage(damage)

    # Log the attack
    CombatLog.create!(
      character_id: character.id,
      enemy_id: enemy.id,
      log_entry: "#{character.name} attacked #{enemy.name} and dealt #{damage} damage.",
      combat_id: enemy.current_combat.id,
      attacker_type: "Character",
      attacker_id: character.id
    )

    # If the enemy is still alive, queue the next attack
    if enemy.alive?
      EnemyAttackJob.set(wait: 5.seconds).perform_later(enemy_id, character_id)
    end
  end
end
