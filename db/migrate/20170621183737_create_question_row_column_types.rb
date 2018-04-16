class CreateQuestionRowColumnTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_column_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_row_column_types, :deleted_at
  end
end
