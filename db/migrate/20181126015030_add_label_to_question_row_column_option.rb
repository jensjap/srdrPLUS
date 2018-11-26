class AddLabelToQuestionRowColumnOption < ActiveRecord::Migration[5.0]
  def change
    add_column :question_row_column_options, :label, :string
  end
end
