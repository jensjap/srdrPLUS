class CreateTpsComparisonsRssms < ActiveRecord::Migration[5.0]
  def change
    create_table :tps_comparisons_rssms do |t|
      t.references :timepoint
      t.references :comparison,                        foreign_key: true, index: { name: 'index_tps_comparisons_rssms_on_comparison_id' }
      t.references :result_statistic_sections_measure, foreign_key: true, index: { name: 'index_tps_comparisons_rssms_on_rssm_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_foreign_key :tps_comparisons_rssms, :extractions_extraction_forms_projects_sections_type1_row_columns, column: :timepoint_id
    add_index :tps_comparisons_rssms, :deleted_at
    add_index :tps_comparisons_rssms, :active
  end
end
