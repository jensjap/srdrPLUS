class CreateKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :key_questions_projects do |t|
      t.references :key_question, foreign_key: true
      t.references :project, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :key_questions_projects, :deleted_at
    add_index :key_questions_projects, :active
    add_index :key_questions_projects, [:key_question_id, :project_id],          name: 'index_kqp_on_kq_id_p_id', where: 'deleted_at IS NULL'
    add_index :key_questions_projects, [:key_question_id, :project_id, :active], name: 'index_kqp_on_kq_id_p_id_active'
  end
end
