class CombatParticipant < ApplicationRecord
  belongs_to :combat
  belongs_to :participant, polymorphic: true
end
