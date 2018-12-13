class AddResultStatisticSectionTypesMeasureToResultStatisticSectionTypesMeasures < ActiveRecord::Migration[5.0]
  def change
    add_reference :result_statistic_section_types_measures, :result_statistic_section_types_measure, foreign_key: true, index: { name: 'index_rsstm_on_rsstm_id' }
  end
end
