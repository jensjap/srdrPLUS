class AddPositionToAbstractScreeningsReasons < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screenings_reasons, :position, :integer
  end
end
