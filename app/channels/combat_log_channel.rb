# app/channels/combat_log_channel.rb
class CombatLogChannel < ApplicationCable::Channel
  def subscribed
    if params[:character_id]
      stream_from "combat_log_#{params[:character_id]}"
    elsif params[:enemy_id]
      stream_from "combat_log_#{params[:enemy_id]}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
