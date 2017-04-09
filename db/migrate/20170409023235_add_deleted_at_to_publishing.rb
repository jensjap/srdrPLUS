class AddDeletedAtToPublishing < ActiveRecord::Migration[5.0]
  def change
    add_column :publishings, :deleted_at, :datetime
    add_index :publishings, :deleted_at
  end
end
