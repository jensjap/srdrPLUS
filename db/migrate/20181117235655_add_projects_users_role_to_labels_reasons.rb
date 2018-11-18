class AddProjectsUsersRoleToLabelsReasons < ActiveRecord::Migration[5.0]
  def change
    add_reference :labels_reasons, :projects_users_role, foreign_key: true
  end
end
