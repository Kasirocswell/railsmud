class AddItemTypeAndAttributesToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :item_type, :integer, default: 0 unless column_exists?(:items, :item_type)
    add_column :items, :damage, :integer, default: 0 unless column_exists?(:items, :damage)
    add_column :items, :effect, :string, default: "" unless column_exists?(:items, :effect)
    add_column :items, :defense, :integer, default: 0 unless column_exists?(:items, :defense)
    add_column :items, :effect_description, :string, default: "" unless column_exists?(:items, :effect_description)
    add_column :items, :speed_bonus, :integer, default: 0 unless column_exists?(:items, :speed_bonus)
    add_column :items, :rarity, :string, default: "common" unless column_exists?(:items, :rarity)
  end
end
