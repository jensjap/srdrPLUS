class AddDeletedAtToComparates < ActiveRecord::Migration[5.0]
  def change
    add_column :comparates, :deleted_at, :datetime
    add_index :comparates, :deleted_at
  end
end
