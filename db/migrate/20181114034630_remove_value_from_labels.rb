class RemoveValueFromLabels < ActiveRecord::Migration[5.0]
  def change
    remove_column :labels, :value, :string
  end
end
