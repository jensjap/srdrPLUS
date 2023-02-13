class AddPermissionsToProjectsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :projects_users, :permissions, :integer, default: 0, null: false
  end
end
