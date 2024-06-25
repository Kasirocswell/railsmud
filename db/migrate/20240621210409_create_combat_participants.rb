class CreateCombatParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :combat_participants do |t|
      t.references :combat, null: false, foreign_key: true
      t.references :participant, polymorphic: true, null: false

      t.timestamps
    end
  end
end
