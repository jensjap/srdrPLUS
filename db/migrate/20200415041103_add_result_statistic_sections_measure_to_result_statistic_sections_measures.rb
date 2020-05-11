class AddResultStatisticSectionsMeasureToResultStatisticSectionsMeasures < ActiveRecord::Migration[5.2]
  def change
    add_reference :result_statistic_sections_measures, :result_statistic_sections_measure, foreign_key: true, index: { name: 'index_rssm_on_rssm_id' }, type: :integer
  end
end
