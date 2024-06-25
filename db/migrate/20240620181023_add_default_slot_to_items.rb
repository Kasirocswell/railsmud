class AddDefaultSlotToItems < ActiveRecord::Migration[6.1]
  def change
    change_column_default :items, :slot, 'misc'
    Item.where(slot: nil).update_all(slot: 'misc')
  end
end
