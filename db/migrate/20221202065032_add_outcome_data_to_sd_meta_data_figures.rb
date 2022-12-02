class AddOutcomeDataToSdMetaDataFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :sd_meta_data_figures, :outcome_type, :string
    add_column :sd_meta_data_figures, :intervention_name, :string
    add_column :sd_meta_data_figures, :comparator_name, :string
    add_column :sd_meta_data_figures, :effect_size_measure_name, :string
    add_column :sd_meta_data_figures, :overall_effect_size, :float
    add_column :sd_meta_data_figures, :overall_95_ci_low, :float
    add_column :sd_meta_data_figures, :overall_95_ci_high, :float
    add_column :sd_meta_data_figures, :overall_i_squared, :float
  end
end
