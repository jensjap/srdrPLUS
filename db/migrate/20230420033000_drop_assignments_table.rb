class DropAssignmentsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :assignments, if_exists: true
  end
end
