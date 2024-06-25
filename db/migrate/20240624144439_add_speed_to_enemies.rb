class AddSpeedToEnemies < ActiveRecord::Migration[7.0]
  def change
    add_column :enemies, :speed, :integer, default: 5
  end
end
