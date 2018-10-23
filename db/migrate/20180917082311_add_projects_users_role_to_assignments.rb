class AddProjectsUsersRoleToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_reference :assignments, :projects_users_role, foreign_key: true
  end
end
