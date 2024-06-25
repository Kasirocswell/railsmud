class CreateCharacters < ActiveRecord::Migration[6.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.string :race
      t.string :character_class
      t.string :subclass
      t.integer :level, default: 1
      t.integer :health
      t.integer :attack_points
      t.integer :strength
      t.integer :intelligence
      t.integer :dexterity
      t.integer :speed
      t.integer :constitution
      t.integer :charisma
      t.integer :luck
      t.integer :wisdom
      t.text :inventory
      t.integer :credits
      t.integer :xp
      t.integer :xp_until_next_level
      t.integer :current_room_id  # Change from references to integer

      t.timestamps
    end

    add_foreign_key :characters, :rooms, column: :current_room_id
  end
end
