class AddHelpKeyToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :help_key, :string
    add_index :messages, :help_key
  end
end
