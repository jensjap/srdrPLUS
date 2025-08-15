class CreateEmailNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :email_notifications do |t|
      t.integer :user_id, null: false 
      t.string :email
      t.string :notification_hash
      t.boolean :successful

      t.timestamps
    end
  end
end
