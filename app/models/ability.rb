class Ability < ApplicationRecord
  has_many :character_abilities, dependent: :destroy
  has_many :characters, through: :character_abilities

  validates :name, :description, presence: true
end
