class AddDeletedAtToKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :key_questions_projects, :deleted_at, :datetime
    add_index :key_questions_projects, :deleted_at
  end
end
