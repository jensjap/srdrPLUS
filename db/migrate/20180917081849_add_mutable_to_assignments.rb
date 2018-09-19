class AddMutableToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :mutable, :boolean, default: true
  end
end
