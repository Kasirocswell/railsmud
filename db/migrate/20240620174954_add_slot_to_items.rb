class AddSlotToItems < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:items, :slot)
      add_column :items, :slot, :string
    end
  end
end
