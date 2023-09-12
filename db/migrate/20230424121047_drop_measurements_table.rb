class DropMeasurementsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :measurements, if_exists: true
  end
end
