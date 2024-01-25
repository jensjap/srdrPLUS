class RemoveRoomFromMessagesAddRoomId < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :room
    add_reference :messages, :room, index: true, null: false
    add_index :messages, %i[user_id room_id]
  end
end
