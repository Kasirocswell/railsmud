class MakePolymorphicColumnsNonNullableAndRemoveOldColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_null :combat_participants, :participant_type, false
    change_column_null :combat_participants, :participant_id, false

    if column_exists?(:combat_participants, :character_id)
      remove_reference :combat_participants, :character, index: true
    end

    if column_exists?(:combat_participants, :enemy_id)
      remove_reference :combat_participants, :enemy, index: true
    end
  end
end
