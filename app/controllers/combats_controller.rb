class CombatsController < ApplicationController
  def create
    character = Character.find(params[:id])
    enemy = Enemy.find(params[:enemy_id])
    combat = Combat.start_combat(character, enemy)

    character.attack(enemy)

    # Schedule the enemy to attack back
    EnemyAttackJob.set(wait: enemy.attack_speed.seconds).perform_later(enemy.id, character.id)

    render json: { combat: combat, log: combat.combat_logs.last }
  end
end
