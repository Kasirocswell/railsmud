class CombatLog < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :enemy, optional: true
  belongs_to :combat
  belongs_to :attacker, polymorphic: true

  validates :log_entry, presence: true
end
