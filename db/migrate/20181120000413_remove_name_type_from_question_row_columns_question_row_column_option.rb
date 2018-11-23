class RemoveNameTypeFromQuestionRowColumnsQuestionRowColumnOption < ActiveRecord::Migration[5.0]
  def change
    remove_column :question_row_columns_question_row_column_options, :name_type, :string
  end
end
