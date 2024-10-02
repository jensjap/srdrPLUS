class AddDremeFieldsToProjectsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :projects_users, :interest_areas, :text
    add_column :projects_users, :additional_rrs, :text
    add_column :projects_users, :availability_notes, :text
  end
end
