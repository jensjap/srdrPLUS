class CreateTpsArmsRssms < ActiveRecord::Migration[5.0]
  def change
    create_table :tps_arms_rssms do |t|
      t.references :extractions_extraction_forms_projects_sections_type1_row, foreign_key: true, index: { name: 'index_tps_arms_rssms_on_eefpstr_id' }
      t.references :extractions_extraction_forms_projects_sections_type1,     foreign_key: true, index: { name: 'index_tps_arms_rssms_on_eefpst_id' }
      t.references :result_statistic_sections_measure,                        foreign_key: true, index: { name: 'index_tps_arms_rssms_on_rssm_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :tps_arms_rssms, :deleted_at
    add_index :tps_arms_rssms, :active
  end
end
