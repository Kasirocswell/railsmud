class AbilitiesController < ApplicationController
  def use
    @character = Character.find(params[:character_id])
    @ability = Ability.find(params[:ability_id])
    @target = Character.find(params[:target_id]) if params[:target_id].present?
    @target = Enemy.find(params[:enemy_id]) if params[:enemy_id].present?

    result = @character.use_ability(@ability, @target)
    render json: { message: result }
  end
end
