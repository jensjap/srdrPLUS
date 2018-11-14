class AddDeletedAtToTaggings < ActiveRecord::Migration[5.0]
  def change
    add_column :taggings, :deleted_at, :datetime
    add_index :taggings, :deleted_at
  end
end
