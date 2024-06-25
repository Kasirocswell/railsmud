class AddEquippedToItems < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:items, :equipped)
      add_column :items, :equipped, :boolean, default: false
    end
  end
end
