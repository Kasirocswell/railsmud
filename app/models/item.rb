class Item < ApplicationRecord
  belongs_to :inventory, optional: true
  belongs_to :room, optional: true

  validates :name, presence: true
  validates :slot, presence: true, unless: -> { item_type == 'usable' }
  validates :item_type, presence: true
  validates :description, presence: true

  enum item_type: { weapon: 0, armor: 1, usable: 2, mount: 3, vehicle: 4 }

  # Weapon attributes
  attribute :damage, :integer, default: 0
  attribute :effect, :string, default: ""

  # Armor attributes
  attribute :defense, :integer, default: 0

  # Usable item attributes
  attribute :effect_description, :string, default: ""

  # Mount and vehicle attributes
  attribute :speed_bonus, :integer, default: 0

  # Rarity attribute for special items
  attribute :rarity, :string, default: "common"

  def use_item(character)
    puts "Using item: #{name}, type: #{item_type}"
    return "This item cannot be used." unless item_type == 'usable'
  
    case name
    when 'Health Potion'
      heal_amount = 50
      character.update!(health: [character.health + heal_amount, 100].min)
      self.destroy
      "You used a Health Potion and restored #{heal_amount} health points."
    else
      "This item cannot be used."
    end
  end  
end
