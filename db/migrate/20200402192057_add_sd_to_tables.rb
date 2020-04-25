class AddSdToTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :network_meta_analysis_results , :sd_network_meta_analysis_results
  end
end
