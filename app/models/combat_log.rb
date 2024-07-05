class CombatLog < ApplicationRecord
  belongs_to :combat
  belongs_to :character, optional: true
  belongs_to :enemy, optional: true

  validates :log_entry, presence: true

  after_create_commit do
    broadcast_append_to "combat_log_#{character_id}", target: "combat_logs"
    Rails.logger.info "Broadcasting to combat_log_#{character_id}: #{log_entry}"
  end
end
