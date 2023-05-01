class CreatePublicationReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :publication_reminders do |t|
      t.integer :user_id, null: false, foreign_key: true
      t.integer :project_id, null: false, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
