class CreateProjectsStudies < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_studies do |t|
      t.references :project, foreign_key: true
      t.references :study, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
  end
end
