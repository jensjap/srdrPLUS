class CreateAssignmentsRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments_rooms do |t|
      t.references :assignment
      t.references :room

      t.timestamps
    end

    add_index :assignments_rooms, %i[assignment_id room_id], unique: true
  end
end
