class AddApprovedOnToExtractions < ActiveRecord::Migration[7.0]
  def change
    add_column :extractions, :approved_on, :datetime
  end
end
