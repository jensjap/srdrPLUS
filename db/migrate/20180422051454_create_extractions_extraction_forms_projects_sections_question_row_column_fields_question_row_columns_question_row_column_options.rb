class CreateExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :eefpsqrcf_qrcqrcos do |t|
      t.references :eefps_qrcf,                                       foreign_key: true, index: { name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id' }
      t.references :question_row_columns_question_row_column_option,  foreign_key: true, index: { name: 'index_eefpsqrcfqrcqrco_on_qrcqrco_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :eefpsqrcf_qrcqrcos, :deleted_at
    add_index :eefpsqrcf_qrcqrcos, :active
    add_index :eefpsqrcf_qrcqrcos, [:eefps_qrcf_id, :question_row_columns_question_row_column_option_id, :deleted_at], name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :eefpsqrcf_qrcqrcos, [:eefps_qrcf_id, :question_row_columns_question_row_column_option_id, :active],     name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_active'
  end
end
