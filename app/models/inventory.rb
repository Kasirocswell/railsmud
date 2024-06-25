class Inventory < ApplicationRecord
  belongs_to :character
  has_many :items, dependent: :destroy

  def equip(item)
    if item.item_type == 'weapon' || item.item_type == 'armor'
      if items.find_by(slot: item.slot, equipped: true)
        "You already have an item equipped in the #{item.slot} slot."
      else
        item.update(equipped: true)
        "You have equipped the #{item.name}."
      end
    else
      "This item cannot be equipped."
    end
  end

  def unequip(item)
    if items.include?(item) && item.equipped
      item.update(equipped: false)
      "You have unequipped the #{item.name}."
    else
      "You don't have the #{item.name} equipped."
    end
  end

  def list_items
    items.map(&:name).join(', ')
  end

  def list_equipped_items
    items.where(equipped: true).map(&:name).join(', ')
  end

  def equipped_items
    items.where(equipped: true)
  end
end
