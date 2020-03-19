class RemoveLevelOfAnalysisFromSdMetaData < ActiveRecord::Migration[5.2]
  def change
    remove_column :sd_meta_data, :level_of_analysis, :string
  end
end
