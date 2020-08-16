class ChangeEefpsFfs < ActiveRecord::Migration[5.2]
  def change
    change_table :extractions_extraction_forms_projects_sections_followup_fields do |t|
      t.remove_index name:'index_eefpsff_followup_fields_on_deleted_at'
      t.remove_index name:'index_eefpsff_on_followup_field_id'

      t.bigint :extractions_extraction_forms_projects_sections_type1_id
      t.boolean :active

      t.index [:extractions_extraction_forms_projects_section_id, :extractions_extraction_forms_projects_sections_type1_id, :followup_field_id, :active], name: 'index_eefpsff_on_eefps_eefpst1_ff_id', unique: true
    end
  end
end
