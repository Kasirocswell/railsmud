class StatusController < ApplicationController
  def check
    @character = Character.find(params[:character_id])
    render json: { status: @character.health_status }
  end
end
