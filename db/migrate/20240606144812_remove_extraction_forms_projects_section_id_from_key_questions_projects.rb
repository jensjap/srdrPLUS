class RemoveExtractionFormsProjectsSectionIdFromKeyQuestionsProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :key_questions_projects, :extraction_forms_projects_section_id
  end
end
