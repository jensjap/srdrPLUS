class DropExtractionsProjectsUsersRoles < ActiveRecord::Migration[7.0]
  def change
    drop_table :extractions_projects_users_roles
  end
end
