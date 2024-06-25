class RenameAttackPointsToActionPointsInCharacters < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:characters, :attack_points)
      rename_column :characters, :attack_points, :action_points
    end
  end
end
