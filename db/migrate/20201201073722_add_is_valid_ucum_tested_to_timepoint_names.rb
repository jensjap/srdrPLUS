class AddIsValidUcumTestedToTimepointNames < ActiveRecord::Migration[5.2]
  def change
    add_column :timepoint_names, :isValidUCUMTested, :boolean, default: false
  end
end
