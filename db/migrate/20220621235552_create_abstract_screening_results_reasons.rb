class CreateAbstractScreeningResultsReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_results_reasons do |t|
      t.references :abstract_screening_result, null: false, type: :bigint, index: { name: 'asrr_on_asr' }
      t.references :reason, null: false, type: :bigint, index: { name: 'asrr_on_r' }
      t.timestamps
    end
    add_index :abstract_screening_results_reasons, %i[abstract_screening_result_id reason_id],
              unique: true, name: 'asrr_asr_on_r'
  end
end
