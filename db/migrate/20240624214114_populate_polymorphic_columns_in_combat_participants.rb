class PopulatePolymorphicColumnsInCombatParticipants < ActiveRecord::Migration[6.1]
  def up
    CombatParticipant.reset_column_information
    CombatParticipant.find_each do |cp|
      if cp.character_id.present?
        cp.update_columns(participant_type: 'Character', participant_id: cp.character_id)
      elsif cp.enemy_id.present?
        cp.update_columns(participant_type: 'Enemy', participant_id: cp.enemy_id)
      end
    end
  end

  def down
    CombatParticipant.update_all(participant_type: nil, participant_id: nil)
  end
end
