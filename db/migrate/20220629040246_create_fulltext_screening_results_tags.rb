class CreateFulltextScreeningResultsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screening_results_tags do |t|
      t.references :fulltext_screening_result, null: false, type: :bigint, index: { name: 'fsrt_on_fsr' }
      t.references :tag, null: false, type: :bigint, index: { name: 'fsrt_on_t' }
      t.timestamps
    end
    add_index :fulltext_screening_results_tags, %i[fulltext_screening_result_id tag_id],
              unique: true, name: 'fsrt_fsr_on_t'
  end
end
