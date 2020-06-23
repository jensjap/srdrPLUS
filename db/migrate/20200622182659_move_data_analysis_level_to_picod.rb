class MoveDataAnalysisLevelToPicod < ActiveRecord::Migration[5.2]
  def change
    add_reference :sd_picods, :data_analysis_level, foreign_key: true
    remove_reference :sd_meta_data, :data_analysis_level, foreign_key: true
  end
end
