class CreateTempCitationsProjectsCreators < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_citations_projects_creators do |t|
      t.integer :citations_project_id
      t.integer :creator_id
    end

    add_index :temp_citations_projects_creators, :citations_project_id
  end
end
