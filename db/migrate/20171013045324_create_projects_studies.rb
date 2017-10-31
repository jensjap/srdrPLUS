class CreateProjectsStudies < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_studies do |t|
      t.references :project, foreign_key: true
      t.references :study, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :projects_studies, :deleted_at, name: 'index_ps_on_deleted_at'
    add_index :projects_studies, :active,     name: 'index_ps_on_active'
    add_index :projects_studies, [:project_id, :study_id, :deleted_at], name: 'index_ps_on_p_id_s_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :projects_studies, [:project_id, :study_id, :active],     name: 'index_ps_on_p_id_s_id_active'
  end
end
