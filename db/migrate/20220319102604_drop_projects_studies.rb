class DropProjectsStudies < ActiveRecord::Migration[5.2]
  def change
    drop_table :projects_studies
  end
end
