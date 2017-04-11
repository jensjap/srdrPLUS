class AddDeletedAtToMessageType < ActiveRecord::Migration[5.0]
  def change
    add_column :message_types, :deleted_at, :datetime
    add_index :message_types, :deleted_at
  end
end
