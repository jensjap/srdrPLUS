class AddUniqueFkToExtractionFormsProjectsSectionOptions < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key 'extraction_forms_projects_section_options', 'extraction_forms_projects_sections',
                       if_exists: true
    remove_index :extraction_forms_projects_section_options, name: 'index_efpso_on_efps_id_deleted_at',
                                                             if_exists: true
    add_index :extraction_forms_projects_section_options, [:extraction_forms_projects_section_id], unique: true,
                                                                                                   name: 'efpso_on_efps_id'
    add_foreign_key 'extraction_forms_projects_section_options', 'extraction_forms_projects_sections',
                    if_not_exists: true
  end
end
