class CreateExtractionFormsProjectsSections < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_projects_sections do |t|
      t.references :extraction_forms_project,               foreign_key: true, index: { name: 'index_efps_on_efp_id' }
      t.references :extraction_forms_projects_section_type, foreign_key: true, index: { name: 'index_efps_on_efpst_id' }
      t.references :section,                                foreign_key: true, index: { name: 'index_efps_on_s_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extraction_forms_projects_sections, :deleted_at
    add_index :extraction_forms_projects_sections, :active
    add_index :extraction_forms_projects_sections, [:extraction_forms_project_id, :section_id, :deleted_at], name: 'index_efps_on_ef_id_s_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extraction_forms_projects_sections, [:extraction_forms_project_id, :section_id, :active],     name: 'index_efps_on_ef_id_s_id_active'
  end
end
