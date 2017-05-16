class CreateExtractionFormsProjectsSectionsQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_projects_sections_questions do |t|
      t.references :extraction_forms_projects_section, foreign_key: true, index: { name: 'index_efpsq_on_efps_id' }
      t.references :question, foreign_key: true, index: { name: 'index_efpsq_on_q_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extraction_forms_projects_sections_questions, :deleted_at
    add_index :extraction_forms_projects_sections_questions, :active
    add_index :extraction_forms_projects_sections_questions, [:extraction_forms_projects_section_id, :question_id, :deleted_at], name: 'index_efpsq_on_efps_id_q_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extraction_forms_projects_sections_questions, [:extraction_forms_projects_section_id, :question_id, :active],     name: 'index_efpsq_on_efps_id_q_id_active'
  end
end
