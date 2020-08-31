class AddFollowups < ActiveRecord::Migration[5.2]
  def change
    create_table :followup_fields do |t|
      t.bigint  :question_row_columns_question_row_column_option_id
      t.index [:question_row_columns_question_row_column_option_id], name: 'index_followup_fields_on_qrcqrco_id'

      t.timestamps
      t.datetime :deleted_at
      t.index :deleted_at
    end
  end
end
