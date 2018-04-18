class CreateMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :measurements do |t|
      t.references :result_statistic_sections_measures_comparison, foreign_key: true, index: { name: 'index_measurement_on_rssmc_id' }
      t.timestamps
    end
  end
end
