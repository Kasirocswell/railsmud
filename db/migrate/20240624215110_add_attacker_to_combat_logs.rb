class AddAttackerToCombatLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :combat_logs, :attacker, polymorphic: true, null: false
  end
end
