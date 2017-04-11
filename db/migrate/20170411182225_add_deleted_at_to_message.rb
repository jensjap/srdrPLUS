class AddDeletedAtToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :deleted_at, :datetime
    add_index :messages, :deleted_at
  end
end
