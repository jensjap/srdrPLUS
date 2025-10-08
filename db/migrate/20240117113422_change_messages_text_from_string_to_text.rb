class ChangeMessagesTextFromStringToText < ActiveRecord::Migration[7.0]
  def change
    change_column :messages, :text, :text
  end
end
