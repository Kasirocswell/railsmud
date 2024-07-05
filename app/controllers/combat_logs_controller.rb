class CombatLogsController < ApplicationController
  def index
    character = Character.find(params[:id])
    Rails.logger.info "Fetching combat logs for character: #{character.id}"
    
    combat_logs = CombatLog.joins(combat: :combat_participants)
                           .where('combat_participants.participant_id = ? AND combat_participants.participant_type = ? OR combat_logs.character_id = ?',
                                  character.id, 'Character', character.id)
                           .pluck(:log_entry)

    Rails.logger.info "Combat Logs: #{combat_logs}"
    render json: combat_logs
  end
end
