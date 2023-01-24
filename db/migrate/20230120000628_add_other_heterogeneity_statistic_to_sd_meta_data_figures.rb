class AddOtherHeterogeneityStatisticToSdMetaDataFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :sd_meta_data_figures, :other_heterogeneity_statistics, :text
  end
end
