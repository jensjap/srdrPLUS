class AddProjectsUsersRoleToReasons < ActiveRecord::Migration[5.0]
  def change
    add_reference :reasons, :projects_users_role, foreign_key: true
  end
end
