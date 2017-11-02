class CreateCitationsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :citations_projects do |t|
      t.references :citation, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
