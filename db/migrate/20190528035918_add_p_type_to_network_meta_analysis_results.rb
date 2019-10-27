class AddPTypeToNetworkMetaAnalysisResults < ActiveRecord::Migration[5.0]
  def change
    add_column :network_meta_analysis_results, :p_type, :string
  end
end