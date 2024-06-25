class CreateCombatLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :combat_logs do |t|
      t.references :character, null: false, foreign_key: true
      t.references :enemy, null: false, foreign_key: true
      t.text :log_entry

      t.timestamps
    end
  end
end
