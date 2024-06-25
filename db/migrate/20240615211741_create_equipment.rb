class CreateEquipment < ActiveRecord::Migration[6.1]
  def change
    create_table :equipments do |t|
      t.string :name
      t.text :description
      t.string :slot
      t.references :inventory, foreign_key: true

      t.timestamps
    end
  end
end
