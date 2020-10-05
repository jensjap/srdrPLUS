class AddEefpst1ReferenceToEefpsff < ActiveRecord::Migration[5.2]
  def change
    change_table "extractions_extraction_forms_projects_sections_followup_fields" do |t|
      t.boolean "active"
      t.bigint "extractions_extraction_forms_projects_sections_type1_id"
      t.index ["extractions_extraction_forms_projects_section_id", "extractions_extraction_forms_projects_sections_type1_id", "followup_field_id", "active"], name: "index_eefpsff_on_eefps_eefpst1_ff_id", unique: true
    end
  end
end
