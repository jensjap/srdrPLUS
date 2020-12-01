class AddIsValidUcumToTimepointNames < ActiveRecord::Migration[5.2]
  def change
    add_column :timepoint_names, :isValidUCUM, :boolean, default: false
  end
end
