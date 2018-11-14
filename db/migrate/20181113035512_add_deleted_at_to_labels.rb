class AddDeletedAtToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :deleted_at, :datetime
    add_index :labels, :deleted_at
  end
end
