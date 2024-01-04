class AddFsReasonsTagsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :fs_reasons_tags, :boolean, default: true, null: false
  end
end
