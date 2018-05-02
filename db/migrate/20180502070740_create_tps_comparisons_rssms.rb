class CreateTpsComparisonsRssms < ActiveRecord::Migration[5.0]
  def change
    create_table :tps_comparisons_rssms do |t|
      t.references :extractions_extraction_forms_projects_sections_type1_row, foreign_key: true, index: { name: 'index_tps_comparisons_rssms_on_eefpstr_id' }
      t.references :comparison,                                               foreign_key: true, index: { name: 'index_tps_comparisons_rssms_on_comparison_id' }
      t.references :result_statistic_sections_measure,                        foreign_key: true, index: { name: 'index_tps_comparisons_rssms_on_rssm_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :tps_comparisons_rssms, :deleted_at
    add_index :tps_comparisons_rssms, :active
  end
end
