class CreateQuestionRowColumnFieldOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_column_field_options do |t|
      t.references :question_row_column_field, foreign_key: true, index: { name: 'index_qrcfo_on_qrcf_id' }
      t.string :key, default: 'option'
      t.string :value, null: false
      t.string :value_type
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_row_column_field_options, :deleted_at
    add_index :question_row_column_field_options, [:question_row_column_field_id, :deleted_at], name: 'index_qrcfo_on_qrcf_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
