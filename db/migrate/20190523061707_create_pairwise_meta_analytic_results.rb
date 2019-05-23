class CreatePairwiseMetaAnalyticResults < ActiveRecord::Migration[5.2]
  def change
    create_table :pairwise_meta_analytic_results do |t|
      t.text :name
      t.references :sd_meta_datum, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
