class AddPopulationInterventionsComparatorsOutcomesStudydesignsSettingsToSdPicods < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_picods, :population, :string
    add_column :sd_picods, :interventions, :string
    add_column :sd_picods, :comparators, :string
    add_column :sd_picods, :outcomes, :string
    add_column :sd_picods, :study_designs, :string
    add_column :sd_picods, :settings, :string
  end
end
