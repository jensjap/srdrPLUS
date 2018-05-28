class CreateQuestionRowColumnsQuestionRowColumnOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_columns_question_row_column_options do |t|
      t.references :question_row_column,        foreign_key: true, index: { name: 'index_qrcqrco_on_qrc_id' }
      t.references :question_row_column_option, foreign_key: true, index: { name: 'index_qrcqrco_on_qrco_id' }
      t.text :name
      t.string :name_type
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :question_row_columns_question_row_column_options, :deleted_at, name: 'index_qrcqrco_on_deleted_at'
    add_index :question_row_columns_question_row_column_options, :active,     name: 'index_qrcqrco_on_active'
    add_index :question_row_columns_question_row_column_options, [:question_row_column_id, :question_row_column_option_id, :deleted_at], name: 'index_qrcqrco_on_qrc_id_qrco_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :question_row_columns_question_row_column_options, [:question_row_column_id, :question_row_column_option_id, :active],     name: 'index_qrcqrco_on_qrc_id_qrco_id_active'
  end
end
