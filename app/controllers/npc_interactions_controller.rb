class NpcInteractionsController < ApplicationController
  def interact
    @character = Character.find(params[:character_id])
    @npc = Npc.find(params[:npc_id])

    result = @npc.interact(@character)
    render json: { message: result }
  end

  def assign_quest
    @character = Character.find(params[:character_id])
    @npc = Npc.find(params[:npc_id])

    result = @npc.assign_quest(@character)
    render json: { message: result }
  end
end
