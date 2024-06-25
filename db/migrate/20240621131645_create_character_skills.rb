class CreateCharacterSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :character_skills do |t|
      t.references :character, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :level, default: 1

      t.timestamps
    end
  end
end
