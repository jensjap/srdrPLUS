class AddQuestionRowColumnFieldIdToQuestionRowColumnFields < ActiveRecord::Migration[7.0]
  def change
    add_reference :question_row_column_fields, :question_row_column_field, null: true, foreign_key: true, type: :int, index: { name: 'index_qrcfs_on_question_row_column_field_id' }
  end
end
