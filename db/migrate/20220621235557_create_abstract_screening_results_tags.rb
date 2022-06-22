class CreateAbstractScreeningResultsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_results_tags do |t|
      t.references :abstract_screening_result, null: false, type: :bigint, index: { name: 'asrt_on_asr' }
      t.references :tag, null: false, type: :bigint, index: { name: 'asrt_on_t' }
      t.timestamps
    end
    add_index :abstract_screening_results_tags, %i[abstract_screening_result_id tag_id],
              unique: true, name: 'asrt_asr_on_t'
  end
end
