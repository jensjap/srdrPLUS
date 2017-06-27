class CreateQuestionRowColumnFields < ActiveRecord::Migration[5.0]
  def change
    create_table :question_row_column_fields do |t|
      t.references :question_row_column,            foreign_key: true, index: { name: 'index_qrcf_on_qrc_id' }
      t.references :question_row_column_field_type, foreign_key: true, index: { name: 'index_qrcf_on_qrcft_id' }
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_row_column_fields, :deleted_at
  end
end
