class CreateQuestionRows < ActiveRecord::Migration[5.0]
  def change
    create_table :question_rows do |t|
      t.references :question, foreign_key: true
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_rows, :deleted_at
    add_index :question_rows, [:question_id, :deleted_at], name: 'index_qr_on_q_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
