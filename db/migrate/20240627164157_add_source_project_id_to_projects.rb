class AddSourceProjectIdToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :source_project_id, :integer, default: nil
  end
end
