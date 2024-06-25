class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.integer :north_id
      t.integer :south_id
      t.integer :east_id
      t.integer :west_id

      t.timestamps
    end
  end
end

