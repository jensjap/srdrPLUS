class CreateKeyQuestionsProjectsQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :key_questions_projects_questions do |t|
      t.references :key_questions_project, foreign_key: true, index: { name: 'index_kqpq_on_kqp_id' }
      t.references :question,              foreign_key: true, index: { name: 'index_kqpq_on_q_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :key_questions_projects_questions, [:key_questions_project_id, :question_id, :deleted_at], name: 'index_kqpq_on_kqp_id_q_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :key_questions_projects_questions, [:key_questions_project_id, :question_id, :active],     name: 'index_kqpq_on_kqp_id_q_id_active_uniq',     unique: true
  end
end
