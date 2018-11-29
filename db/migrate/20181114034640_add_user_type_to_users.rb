class AddUserTypeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :user_type, foreign_key: true
  end
end
