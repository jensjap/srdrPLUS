class AddMissingIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :active_storage_attachments, :record_id
    add_index :authors_citations, :author_id
    add_index :citations_keywords, :keyword_id
    add_index :extractions_extraction_forms_projects_sections_followup_fields, :extractions_extraction_forms_projects_sections_type1_id, name: 'eefpst1_index'
    add_index :imported_files, :import_id
    add_index :imports, :import_type_id
    add_index :imports, :projects_user_id
    add_index :oauth_access_grants, :resource_owner_id
    add_index :sd_meta_data, :project_id
    add_index :sd_meta_data, :report_accession_id
  end
end
