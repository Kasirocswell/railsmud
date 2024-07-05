# app/channels/combat_log_channel.rb
class CombatLogChannel < ApplicationCable::Channel
  def subscribed
    stream_from "combat_log_#{params[:character_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
