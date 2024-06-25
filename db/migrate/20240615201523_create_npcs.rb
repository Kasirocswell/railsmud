class CreateNpcs < ActiveRecord::Migration[7.1]
  def change
    create_table :npcs do |t|
      t.string :name
      t.text :description
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
