class AddLevelToAbilities < ActiveRecord::Migration[6.1]
  def change
    add_column :abilities, :level, :integer, default: 1, null: false
  end
end
