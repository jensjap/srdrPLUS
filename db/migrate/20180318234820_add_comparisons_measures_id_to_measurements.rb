class AddComparisonsMeasuresIdToMeasurements < ActiveRecord::Migration[5.0]
  def change
    remove_reference :measurements, :result_statistic_sections_measures_comparison
    add_reference :measurements, :comparisons_measure, index: true, foreign_key: true
  end
end
