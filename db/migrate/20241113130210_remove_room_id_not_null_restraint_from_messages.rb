class RemoveRoomIdNotNullRestraintFromMessages < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:messages, :room_id, true)
  end
end
