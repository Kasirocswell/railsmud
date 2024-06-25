class ChangeInventoryIdInItems < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:items, :inventory_id)
      change_column_null :items, :inventory_id, true
    end
  end
end
