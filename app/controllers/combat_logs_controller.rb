class CombatLogsController < ApplicationController
  def index
    @combat_logs = CombatLog.where(character_id: params[:id]).order(created_at: :desc)
    render json: @combat_logs
  end
end
