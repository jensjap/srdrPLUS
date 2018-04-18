class AddDeletedAtToComparateGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :comparate_groups, :deleted_at, :datetime
    add_index :comparate_groups, :deleted_at
  end
end
