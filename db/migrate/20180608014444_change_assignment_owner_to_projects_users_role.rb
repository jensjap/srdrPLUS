class ChangeAssignmentOwnerToProjectsUsersRole < ActiveRecord::Migration[5.0]
  def change
    remove_reference :assignments, :user, foreign_key: true
    add_reference :assignments, :projects_users_role, foreign_key: true
  end
end
