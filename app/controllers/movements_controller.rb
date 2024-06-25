class MovementsController < ApplicationController
  def move
    character = Character.find(params[:character_id])
    direction = params[:direction]
    message = character.move(direction)

    Rails.logger.debug "Move action: Character: #{character.inspect}, Message: #{message}"

    render json: {
      message: message,
      character: character.as_json(include: { current_room: { include: :enemies }, abilities: {}, inventory: { include: :items } })
    }
  end
end
