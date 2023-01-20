class ConvertSdMetaDataFiguresFloatsToString < ActiveRecord::Migration[7.0]
  def change
    change_column :sd_meta_data_figures, :overall_effect_size, :string
    change_column :sd_meta_data_figures, :overall_95_ci_low, :string
    change_column :sd_meta_data_figures, :overall_95_ci_high, :string
    change_column :sd_meta_data_figures, :overall_i_squared, :string
  end
end
