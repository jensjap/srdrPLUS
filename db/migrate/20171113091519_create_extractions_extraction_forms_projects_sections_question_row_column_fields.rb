class CreateExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFields < ActiveRecord::Migration[5.0]
  def change
    create_table :eefps_qrcf do |t|
      t.references :extractions_extraction_forms_projects_sections_type1, foreign_key: true, index: { name: 'index_eefpsqrcf_on_eefpst1_id' }
      t.references :extractions_extraction_forms_projects_section,        foreign_key: true, index: { name: 'index_eefpsqrcf_on_eefps_id' }
      t.references :question_row_column_field,                            foreign_key: true, index: { name: 'index_eefpsqrcf_on_qrcf_id' }
      t.text :name
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :eefps_qrcf, :deleted_at
    add_index :eefps_qrcf, :active
    add_index :eefps_qrcf, [:extractions_extraction_forms_projects_sections_type1_id, :extractions_extraction_forms_projects_section_id, :question_row_column_field_id, :deleted_at], name: 'index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :eefps_qrcf, [:extractions_extraction_forms_projects_sections_type1_id, :extractions_extraction_forms_projects_section_id, :question_row_column_field_id, :active],     name: 'index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_active'
  end
end
