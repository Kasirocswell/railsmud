class CreateCorpses < ActiveRecord::Migration[6.1]
  def change
    create_table :corpses do |t|
      t.references :room, null: false, foreign_key: true
      t.references :character, foreign_key: true
      t.references :enemy, foreign_key: true
      t.text :loot

      t.timestamps
    end
  end
end