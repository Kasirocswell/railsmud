class AddInventoryIdToItems < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:items, :inventory_id)
      add_reference :items, :inventory, foreign_key: true, null: true
    end
  end
end
