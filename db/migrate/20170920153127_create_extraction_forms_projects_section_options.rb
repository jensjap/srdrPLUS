class CreateExtractionFormsProjectsSectionOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_projects_section_options do |t|
      t.references :extraction_forms_projects_section, foreign_key: true, index: { name: 'index_efpso_on_efps_id' }
      t.boolean :by_type1
      t.boolean :include_total
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extraction_forms_projects_section_options, :deleted_at, name: 'index_efpso_on_deleted_at'
    add_index :extraction_forms_projects_section_options, [:extraction_forms_projects_section_id, :deleted_at], name: 'index_efpso_on_efps_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
