class AddDeletedAtToComparisons < ActiveRecord::Migration[5.0]
  def change
    add_column :comparisons, :deleted_at, :datetime
    add_index :comparisons, :deleted_at
  end
end
