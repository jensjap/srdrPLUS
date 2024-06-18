class AddProjectReferenceToRooms < ActiveRecord::Migration[7.0]
  def change
    add_reference :rooms, :project, index: { unique: true }, foreign_key: true, type: :int
  end
end
