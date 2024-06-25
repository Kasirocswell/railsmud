class EnemyAttackJob < ApplicationJob
  queue_as :default

  def perform(enemy_id, character_id)
    enemy = Enemy.find(enemy_id)
    character = Character.find(character_id)

    if enemy.alive? && character.alive?
      enemy.attack(character)
      EnemyAttackJob.set(wait: enemy.attack_speed.seconds).perform_later(enemy_id, character_id)
    else
      enemy.die unless enemy.alive?
    end
  end
end
