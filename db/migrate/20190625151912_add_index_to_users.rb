class AddIndexToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, :email
    add_index :users, [:email, :deleted_at], unique: true
  end
end
