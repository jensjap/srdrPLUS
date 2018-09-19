class RemoveUserFromAssignments < ActiveRecord::Migration[5.0]
  def change
    remove_reference :assignments, :user, foreign_key: true
  end
end
