class CombatsController < ApplicationController
  def create
    character = Character.find(params[:id])
    enemy = Enemy.find(params[:enemy_id])

    Rails.logger.debug { "Initializing combat between #{character.name} and #{enemy.name}" }

    combat = Combat.create!(enemy: enemy, status: Combat::PENDING)
    combat.add_participant(character)
    combat.add_participant(enemy)
    combat.start_combat

    Rails.logger.debug { "Combat status: #{combat.status}" }
    if combat.ongoing?
      Rails.logger.debug { "Combat is ongoing. Executing combat..." }
      combat.execute_combat
    else
      Rails.logger.debug { "Combat not ongoing. Status: #{combat.status}" }
    end

    render json: { combat_logs: combat.combat_logs.pluck(:log_entry) }
  rescue => e
    Rails.logger.error { "Error during combat execution: #{e.message}" }
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
