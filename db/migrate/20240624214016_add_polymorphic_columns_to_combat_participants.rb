class AddPolymorphicColumnsToCombatParticipants < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:combat_participants, :participant_type)
      add_reference :combat_participants, :participant, polymorphic: true, null: true
    end
  end
end
