class CreateResultStatisticSectionsMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :result_statistic_sections_measures do |t|
      t.references :measure, foreign_key: true
      t.references :result_statistic_section, foreign_key: true, index: { name: 'index_rssm_on_rss_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :result_statistic_sections_measures, :deleted_at
    add_index :result_statistic_sections_measures, :active
    add_index :result_statistic_sections_measures, [:measure_id, :result_statistic_section_id, :deleted_at], name: 'index_rssm_on_m_id_rss_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :result_statistic_sections_measures, [:measure_id, :result_statistic_section_id, :active],     name: 'index_rssm_on_m_id_rss_id_active'
  end
end
