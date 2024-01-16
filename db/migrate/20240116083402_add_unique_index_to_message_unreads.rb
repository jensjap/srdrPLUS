class AddUniqueIndexToMessageUnreads < ActiveRecord::Migration[7.0]
  def change
    add_index :message_unreads, %i[user_id message_id], unique: true
  end
end
