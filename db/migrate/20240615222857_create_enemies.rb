class CreateEnemies < ActiveRecord::Migration[6.1]
  def change
    create_table :enemies do |t|
      t.string :name
      t.text :description
      t.integer :health
      t.integer :attack_points
      t.references :room, foreign_key: true

      t.timestamps
    end
  end
end
