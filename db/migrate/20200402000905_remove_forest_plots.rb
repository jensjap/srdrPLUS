class RemoveForestPlots < ActiveRecord::Migration[5.2]
  def change
    drop_table :sd_forest_plots
  end
end
