class AddIsExpertToProjectsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :projects_users, :is_expert, :boolean, default: false
  end
end
