class AllowNullForCharacterAndEnemyInCombatLogs < ActiveRecord::Migration[6.1]
  def change
    change_column_null :combat_logs, :character_id, true
    change_column_null :combat_logs, :enemy_id, true
  end
end
