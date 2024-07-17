# db/migrate/xxxx_add_combat_state_to_characters.rb
class AddCombatStateToCharacters < ActiveRecord::Migration[6.1]
  def change
    add_column :characters, :combat_state, :boolean, default: false
  end
end