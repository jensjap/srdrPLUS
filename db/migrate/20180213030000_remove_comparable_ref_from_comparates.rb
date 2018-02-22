class RemoveComparableRefFromComparates < ActiveRecord::Migration[5.0]
  def change
    remove_column :comparates, :comparable_id
    remove_column :comparates, :comparable_type
  end
end
