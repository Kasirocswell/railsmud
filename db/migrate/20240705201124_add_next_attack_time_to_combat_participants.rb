class AddNextAttackTimeToCombatParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :combat_participants, :next_attack_time, :datetime
  end
end
