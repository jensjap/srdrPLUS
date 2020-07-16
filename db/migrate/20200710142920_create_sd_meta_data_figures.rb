class CreateSdMetaDataFigures < ActiveRecord::Migration[5.2]
  def change
    rename_table :sd_analysis_figures, :sd_meta_data_figures 
    add_column :sd_meta_data_figures, :alt_text, :text
  end
end
