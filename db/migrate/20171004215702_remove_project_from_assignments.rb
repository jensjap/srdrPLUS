class RemoveProjectFromAssignments < ActiveRecord::Migration[5.0]
  def change
    remove_reference :assignments, :project, foreign_key: true
  end
end
