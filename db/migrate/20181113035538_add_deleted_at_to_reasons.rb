class AddDeletedAtToReasons < ActiveRecord::Migration[5.0]
  def change
    add_column :reasons, :deleted_at, :datetime
    add_index :reasons, :deleted_at
  end
end
