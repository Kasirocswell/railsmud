class AddPolymorphicColumnsToCombatParticipants < ActiveRecord::Migration[6.1]
  def change
    add_reference :combat_participants, :participant, polymorphic: true, null: true
  end
end
