class CreateFulltextScreeningResultsReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screening_results_reasons do |t|
      t.references :fulltext_screening_result, null: false, type: :bigint, index: { name: 'fsrr_on_fsr' }
      t.references :reason, null: false, type: :bigint, index: { name: 'fsrr_on_r' }
      t.timestamps
    end
    add_index :fulltext_screening_results_reasons, %i[fulltext_screening_result_id reason_id],
              unique: true, name: 'fsrr_fsr_on_r'
  end
end
