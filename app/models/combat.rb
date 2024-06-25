class Combat < ApplicationRecord
  enum status: { ongoing: 0, completed: 1 }

  belongs_to :enemy
  has_many :combat_participants, dependent: :destroy
  has_many :characters, through: :combat_participants, source: :participant, source_type: 'Character'
  has_many :combat_logs, dependent: :destroy

  def self.start_combat(character, enemy)
    combat = find_or_create_by(enemy: enemy, status: :ongoing)
    Rails.logger.debug "Starting combat: #{combat.inspect}"
    combat.add_participant(character)
    combat.add_participant(enemy)
    Rails.logger.debug "Participants after addition: #{combat.participants.inspect}"
    combat
  end

  def add_participant(participant)
    unless participants.include?(participant)
      Rails.logger.debug "Adding participant: #{participant.inspect}"
      participant_record = combat_participants.create(participant_type: participant.class.name, participant_id: participant.id)
      if participant_record.persisted?
        Rails.logger.debug "Participant added successfully: #{participant_record.inspect}"
      else
        Rails.logger.error "Failed to add participant: #{participant_record.errors.full_messages.join(", ")}"
      end
    else
      Rails.logger.debug "Participant already included: #{participant.inspect}"
    end
  end

  def participants
    combat_participants.each do |cp|
      Rails.logger.debug "CombatParticipant: #{cp.inspect}"
    end
    combat_participants.map(&:participant)
  end
end
