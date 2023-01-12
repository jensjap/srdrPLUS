class AddPositionToAbstractScreeningsTags < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screenings_tags, :position, :integer
  end
end
