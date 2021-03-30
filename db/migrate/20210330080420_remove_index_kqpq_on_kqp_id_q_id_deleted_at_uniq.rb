class RemoveIndexKqpqOnKqpIdQIdDeletedAtUniq < ActiveRecord::Migration[5.2]
  def change
    remove_index :key_questions_projects_questions, name: 'index_kqpq_on_kqp_id_q_id_deleted_at_uniq'
  end
end
