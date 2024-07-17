class Corpse < ApplicationRecord
  belongs_to :room
  belongs_to :character, optional: true
  belongs_to :enemy, optional: true
  serialize :loot, Array

  def add_loot(items)
    self.loot ||= []
    self.loot += items
  end
end
