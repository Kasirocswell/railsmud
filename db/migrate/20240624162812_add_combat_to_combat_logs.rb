class AddCombatToCombatLogs < ActiveRecord::Migration[6.1]
  def change
    add_reference :combat_logs, :combat, foreign_key: true
  end
end
