class CreateQuestionRowColumns < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_columns do |t|
      t.references :question_row,             foreign_key: true
      t.references :question_row_column_type, foreign_key: true, index: { name: 'index_qrc_on_qrct_id' }
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_row_columns, :deleted_at
    add_index :question_row_columns, [:question_row_id, :deleted_at],                               name: 'index_qrc_on_qr_id_deleted_at',         where: 'deleted_at IS NULL'
    add_index :question_row_columns, [:question_row_id, :question_row_column_type_id, :deleted_at], name: 'index_qrc_on_qr_id_qrct_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
