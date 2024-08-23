class DropAssignments < ActiveRecord::Migration[7.0]
  def change
    drop_table :assignments
  end
end
