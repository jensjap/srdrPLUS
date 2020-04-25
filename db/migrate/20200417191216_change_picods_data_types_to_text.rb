class ChangePicodsDataTypesToText < ActiveRecord::Migration[5.2]
  def change
    change_column :sd_picods, :population, :text
    change_column :sd_picods, :interventions, :text
    change_column :sd_picods, :comparators, :text
    change_column :sd_picods, :outcomes, :text
    change_column :sd_picods, :study_designs, :text
    change_column :sd_picods, :settings, :text
  end
end
