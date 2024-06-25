class CharacterSkill < ApplicationRecord
  belongs_to :character
  belongs_to :skill

  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
