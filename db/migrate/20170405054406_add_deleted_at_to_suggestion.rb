class AddDeletedAtToSuggestion < ActiveRecord::Migration[5.0]
  def change
    add_column :suggestions, :deleted_at, :datetime
    add_index :suggestions, :deleted_at
  end
end
