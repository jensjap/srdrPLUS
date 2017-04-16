class AddDeletedAtToKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :key_questions_projects, :deleted_at, :datetime
    add_index :key_questions_projects, :deleted_at
    add_index :key_questions_projects, [:key_question_id, :project_id, :position], where: 'deleted_at IS NULL'
  end
end
