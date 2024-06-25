class CreateCombats < ActiveRecord::Migration[7.0]
  def change
    create_table :combats do |t|
      t.references :enemy, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
