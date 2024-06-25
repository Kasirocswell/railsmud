class RemoveCharacterIdFromAbilities < ActiveRecord::Migration[7.0]
  def change
    remove_column :abilities, :character_id, :integer
  end
end
