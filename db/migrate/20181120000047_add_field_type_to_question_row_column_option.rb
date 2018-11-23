class AddFieldTypeToQuestionRowColumnOption < ActiveRecord::Migration[5.0]
  def change
    add_column :question_row_column_options, :field_type, :string
  end
end
