class AddDefenseToEnemies < ActiveRecord::Migration[7.1]
  def change
    add_column :enemies, :defense, :integer
  end
end
