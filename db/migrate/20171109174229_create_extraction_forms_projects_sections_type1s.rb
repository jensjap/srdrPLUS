class CreateExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_projects_sections_type1s do |t|
      t.references :extraction_forms_projects_section, foreign_key: true, index: { name: 'index_efpst1_on_efps_id' }
      t.references :type1,                             foreign_key: true, index: { name: 'index_efpst1_on_t1_id' }
      t.references :type1_type,                        foreign_key: true, index: { name: 'index_efpst1_on_t1_type_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extraction_forms_projects_sections_type1s, :deleted_at
    add_index :extraction_forms_projects_sections_type1s, :active
    add_index :extraction_forms_projects_sections_type1s, [:extraction_forms_projects_section_id, :type1_id, :type1_type_id, :deleted_at], name: 'index_efpst1_on_efps_id_t1_id_t1_type_id_deleted_at_uniq', where: 'deleted_at IS NULL', unique: true
    add_index :extraction_forms_projects_sections_type1s, [:extraction_forms_projects_section_id, :type1_id, :type1_type_id, :active],     name: 'index_efpst1_on_efps_id_t1_id_t1_type_id_active_uniq',                                  unique: true
  end
end
