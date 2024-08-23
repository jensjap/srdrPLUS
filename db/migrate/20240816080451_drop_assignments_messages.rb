class DropAssignmentsMessages < ActiveRecord::Migration[7.0]
  def change
    drop_table :assignments_messages
  end
end
