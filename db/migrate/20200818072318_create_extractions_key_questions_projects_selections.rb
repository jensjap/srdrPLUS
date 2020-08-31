class CreateExtractionsKeyQuestionsProjectsSelections < ActiveRecord::Migration[5.2]
  def change
    create_table :extractions_key_questions_projects_selections do |t|
      t.references :extraction, index: { name: 'index_ekqps_on_extractions_id' }
      t.references :key_questions_project, index: { name: 'index_ekqps_on_key_questions_projects_id' }
      t.timestamps
    end
  end
end
