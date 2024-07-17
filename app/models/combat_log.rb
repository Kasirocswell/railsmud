class CombatLog < ApplicationRecord
  belongs_to :combat
  belongs_to :character, optional: true
  belongs_to :enemy, optional: true
  belongs_to :attacker, polymorphic: true

  validates :log_entry, presence: true

  after_create_commit do
    channel = character_id ? "combat_log_#{character_id}" : "combat_log_#{enemy_id}"
    broadcast_append_to channel, target: "combat_logs"
    Rails.logger.info "Broadcasting to #{channel}: #{log_entry}"
  end
end
