class CreateMessageUnreads < ActiveRecord::Migration[7.0]
  def change
    create_table :message_unreads do |t|
      t.references :user, null: false
      t.references :message, null: false

      t.timestamps
    end
  end
end
