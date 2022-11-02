class AddProjectsPaginatePerToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :projects_paginate_per, :integer
  end
end
