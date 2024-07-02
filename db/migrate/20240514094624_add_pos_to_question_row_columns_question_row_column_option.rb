class AddPosToQuestionRowColumnsQuestionRowColumnOption < ActiveRecord::Migration[7.0]
  def change
    add_column :question_row_columns_question_row_column_options, :pos, :integer, default: 999_999
    add_index :question_row_columns_question_row_column_options, :pos
  end
end
