class CreateCharacterAbilities < ActiveRecord::Migration[7.1]
  def change
    create_table :character_abilities do |t|
      t.references :character, null: false, foreign_key: true
      t.references :ability, null: false, foreign_key: true

      t.timestamps
    end
  end
end
