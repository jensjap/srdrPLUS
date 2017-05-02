class CreateMessageTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :message_types do |t|
      t.string :name
      t.references :frequency, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :message_types, :deleted_at
  end
end
