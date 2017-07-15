class CreateQuestionRowColumnFieldOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_column_field_options do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_row_column_field_options, :deleted_at
  end
end
