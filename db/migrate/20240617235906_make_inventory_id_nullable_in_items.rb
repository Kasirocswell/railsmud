class MakeInventoryIdNullableInItems < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:items, :inventory_id)
      change_column :items, :inventory_id, :integer, null: true
    end
  end
end
