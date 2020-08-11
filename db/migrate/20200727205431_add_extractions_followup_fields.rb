class AddExtractionsFollowupFields < ActiveRecord::Migration[5.2]
  def change
    create_table :extractions_extraction_forms_projects_sections_followup_fields do |t|
      t.bigint :extractions_extraction_forms_projects_section_id
      t.bigint :followup_field_id
      t.index [:followup_field_id], name: 'index_eefpsff_on_followup_field_id'
      t.index [:extractions_extraction_forms_projects_section_id], name: 'index_eefpsff_followup_fields_on_extraction_id'

      t.timestamps
      t.datetime :deleted_at
      t.index :deleted_at, name: 'index_eefpsff_followup_fields_on_deleted_at'
    end
  end
end
