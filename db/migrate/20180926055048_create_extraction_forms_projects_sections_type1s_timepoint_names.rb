class CreateExtractionFormsProjectsSectionsType1sTimepointNames < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_projects_sections_type1s_timepoint_names do |t|
      t.references :extraction_forms_projects_sections_type1, foreign_key: true, index: { name: 'index_efpst1tn_on_efpst1_id' }
      t.references :timepoint_name,                           foreign_key: true, index: { name: 'index_efpst1tn_on_tn_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extraction_forms_projects_sections_type1s_timepoint_names, :deleted_at, name: 'index_efpst1tn_on_deleted_at'
    add_index :extraction_forms_projects_sections_type1s_timepoint_names, :active,     name: 'index_efpst1tn_on_active'
    add_index :extraction_forms_projects_sections_type1s_timepoint_names, [:extraction_forms_projects_sections_type1_id, :timepoint_name_id, :deleted_at], name: 'index_efpst1tn_on_efpst1_id_tn_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extraction_forms_projects_sections_type1s_timepoint_names, [:extraction_forms_projects_sections_type1_id, :timepoint_name_id, :active],     name: 'index_efpst1tn_on_efpst1_id_tn_id_active'
  end
end
