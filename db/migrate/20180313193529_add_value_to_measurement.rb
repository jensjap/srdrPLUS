class AddValueToMeasurement < ActiveRecord::Migration[5.0]
  def change
    add_column :measurements, :value, :string
  end
end
