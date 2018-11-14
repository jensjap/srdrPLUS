class AddDeletedAtToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :deleted_at, :datetime
    add_index :tags, :deleted_at
  end
end
