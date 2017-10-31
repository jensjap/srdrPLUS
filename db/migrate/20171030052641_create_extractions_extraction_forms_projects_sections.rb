class CreateExtractionsExtractionFormsProjectsSections < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_extraction_forms_projects_sections do |t|
      t.references :extraction, foreign_key: true,                        index: { name: 'index_eefps_on_e_id' }
      t.references :extraction_forms_projects_section, foreign_key: true, index: { name: 'index_eefps_on_efps_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extractions_extraction_forms_projects_sections, :deleted_at, name: 'index_eefps_on_deleted_at'
    add_index :extractions_extraction_forms_projects_sections, :active,     name: 'index_eefps_on_active'
    add_index :extractions_extraction_forms_projects_sections, [:extraction_id, :extraction_forms_projects_section_id, :deleted_at], name: 'index_eefps_on_e_id_efps_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extractions_extraction_forms_projects_sections, [:extraction_id, :extraction_forms_projects_section_id, :active],     name: 'index_eefps_on_e_id_efps_id_active'
  end
end
