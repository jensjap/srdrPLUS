class CreateComparisonsResultStatisticSections < ActiveRecord::Migration[5.0]
  def change
    create_table :comparisons_result_statistic_sections do |t|
      t.references :comparison,               foreign_key: true, index: { name: 'index_crss_on_c_id' }
      t.references :result_statistic_section, foreign_key: true, index: { name: 'index_crss_on_rss_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :comparisons_result_statistic_sections, :deleted_at
    add_index :comparisons_result_statistic_sections, :active
    add_index :comparisons_result_statistic_sections, [:comparison_id, :result_statistic_section_id, :deleted_at], name: 'index_crss_on_c_id_rss_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :comparisons_result_statistic_sections, [:comparison_id, :result_statistic_section_id, :active],     name: 'index_crss_on_c_id_rss_id_active'
  end
end
