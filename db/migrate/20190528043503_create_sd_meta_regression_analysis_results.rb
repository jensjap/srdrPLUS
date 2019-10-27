class CreateSdMetaRegressionAnalysisResults < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_meta_regression_analysis_results do |t|
      t.text :name
      t.references :sd_meta_datum, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
