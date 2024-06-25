class AddAggressionLevelToEnemies < ActiveRecord::Migration[6.1]
  def change
    add_column :enemies, :aggression_level, :integer, default: 0
  end
end
