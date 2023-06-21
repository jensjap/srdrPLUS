class AddOnlineStatusToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :online_status, :string, default: 'offline', null: false
  end
end
