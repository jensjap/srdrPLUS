class AddPTypeToPairwiseMetaAnalyticResults < ActiveRecord::Migration[5.0]
  def change
    add_column :pairwise_meta_analytic_results, :p_type, :string
  end
end