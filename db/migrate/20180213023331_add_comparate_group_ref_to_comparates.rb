class AddComparateGroupRefToComparates < ActiveRecord::Migration[5.0]
  def change
    add_reference :comparates, :comparate_group, foreign_key: true
  end
end
