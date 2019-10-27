class CreateNetworkMetaAnalysisResults < ActiveRecord::Migration[5.2]
  def change
    create_table :network_meta_analysis_results do |t|
      t.text :name
      t.references :sd_meta_datum, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
