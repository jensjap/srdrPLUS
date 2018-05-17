class CreateCitationsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :citations_projects do |t|
      t.references :citation, foreign_key: true
      t.references :project, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :citations_projects, :deleted_at
    add_index :citations_projects, :active
  end
end
