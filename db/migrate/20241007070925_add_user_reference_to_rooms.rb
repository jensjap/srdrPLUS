class AddUserReferenceToRooms < ActiveRecord::Migration[7.0]
  def change
    add_reference :rooms, :user, null: false, type: :int, index: true
  end
end
