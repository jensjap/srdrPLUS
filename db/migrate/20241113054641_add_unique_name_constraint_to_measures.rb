class AddUniqueNameConstraintToMeasures < ActiveRecord::Migration[7.0]
  def change
    add_index :measures, [:name], unique: true
  end
end
