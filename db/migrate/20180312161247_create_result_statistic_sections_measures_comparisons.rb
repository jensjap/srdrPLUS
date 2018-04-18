class CreateResultStatisticSectionsMeasuresComparisons < ActiveRecord::Migration[5.0]
  def change
    create_table :result_statistic_sections_measures_comparisons do |t|
      t.references :result_statistic_section, foreign_key: true, index: { name: 'index_rssmc_on_rss_id' } 
      t.references :comparison, foreign_key: true, index: { name: 'index_rssmc_on_comparison_id' }
      t.timestamps
    end
  end
end
