class AddNotificationToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :notification, :string, default: 'email'
  end
end
