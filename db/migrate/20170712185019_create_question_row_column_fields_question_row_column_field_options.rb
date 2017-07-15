class CreateQuestionRowColumnFieldsQuestionRowColumnFieldOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_column_fields_question_row_column_field_options do |t|
      t.references :question_row_column_field,        foreign_key: true, index: { name: 'index_qrcfqrcfo_on_qrcf_id' }
      t.references :question_row_column_field_option, foreign_key: true, index: { name: 'index_qrcfqrcfo_on_qrcfo_id' }
      t.string :value
      t.string :value_type
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :question_row_column_fields_question_row_column_field_options, :deleted_at, name: 'index_qrcfqrcfo_on_deleted_at'
    add_index :question_row_column_fields_question_row_column_field_options, :active,     name: 'index_qrcfqrcfo_on_active'
    add_index :question_row_column_fields_question_row_column_field_options, [:question_row_column_field_id, :question_row_column_field_option_id, :deleted_at], name: 'index_qrcfqrcfo_on_qrcf_id_qrcfo_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :question_row_column_fields_question_row_column_field_options, [:question_row_column_field_id, :question_row_column_field_option_id, :active],     name: 'index_qrcfqrcfo_on_qrcf_id_qrcfo_id_active'
  end
end
