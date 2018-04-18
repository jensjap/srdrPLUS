class AddDeletedAtToComparableElememnts < ActiveRecord::Migration[5.0]
  def change
    add_column :comparable_elements, :deleted_at, :datetime
    add_index :comparable_elements, :deleted_at
  end
end
