class AddAliveToEnemies < ActiveRecord::Migration[6.1]
  def change
    add_column :enemies, :alive, :boolean, default: true
  end
end
