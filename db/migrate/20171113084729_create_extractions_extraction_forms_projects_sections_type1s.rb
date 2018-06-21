class CreateExtractionsExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_extraction_forms_projects_sections_type1s do |t|
      t.references :type1_type,                                    foreign_key: true, index: { name: 'index_eefpst1_on_t1t_id' }
      t.references :extractions_extraction_forms_projects_section, foreign_key: true, index: { name: 'index_eefpst1_on_eefps_id' }
      t.references :type1,                                         foreign_key: true, index: { name: 'index_eefpst1_on_t1_id' }
      t.string     :units  # What is this?
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extractions_extraction_forms_projects_sections_type1s, :deleted_at, name: 'index_eefpst1_on_deleted_at'
    add_index :extractions_extraction_forms_projects_sections_type1s, :active,     name: 'index_eefpst1_on_active'
    add_index :extractions_extraction_forms_projects_sections_type1s, [:type1_type_id, :extractions_extraction_forms_projects_section_id, :type1_id, :deleted_at], name: 'index_eefpst1_on_t1t_id_eefps_id_t1_id_deleted_at', unique: true, where: 'deleted_at IS NULL'
    add_index :extractions_extraction_forms_projects_sections_type1s, [:type1_type_id, :extractions_extraction_forms_projects_section_id, :type1_id, :active],     name: 'index_eefpst1_on_t1t_id_eefps_id_t1_id_active',     unique: true
  end
end
