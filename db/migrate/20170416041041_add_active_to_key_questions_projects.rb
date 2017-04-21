class AddActiveToKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :key_questions_projects, :active, :boolean
    add_index :key_questions_projects, :active
    add_index :key_questions_projects, [:key_question_id, :project_id, :active], name: 'index_kqp_on_kq_id_p_id_active_uniq', unique: true
  end
end
