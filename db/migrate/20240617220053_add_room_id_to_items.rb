class AddRoomIdToItems < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:items, :room_id)
      add_reference :items, :room, foreign_key: true, null: true
    end
  end
end
