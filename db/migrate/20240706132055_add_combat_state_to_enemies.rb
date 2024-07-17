# db/migrate/xxxx_add_combat_state_to_enemies.rb
class AddCombatStateToEnemies < ActiveRecord::Migration[6.1]
  def change
    add_column :enemies, :combat_state, :boolean, default: false
  end
end