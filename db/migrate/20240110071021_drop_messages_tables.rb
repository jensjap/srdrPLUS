class DropMessagesTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :messages
    drop_table :message_types
    drop_table :frequencies
    drop_table :dispatches
  end
end
