class AddDeletedAtToDispatch < ActiveRecord::Migration[5.0]
  def change
    add_column :dispatches, :deleted_at, :datetime
    add_index :dispatches, :deleted_at
  end
end
