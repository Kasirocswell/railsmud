class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :slot
      t.integer :item_type, null: false
      t.integer :damage, default: 0
      t.string :effect, default: ""
      t.integer :defense, default: 0
      t.string :effect_description, default: ""
      t.integer :speed_bonus, default: 0
      t.string :rarity, default: "common"
      t.text :description, null: false
      t.references :inventory, foreign_key: true, null: true
      t.references :room, foreign_key: true, null: true
      t.boolean :equipped, default: false

      t.timestamps
    end
  end
end
