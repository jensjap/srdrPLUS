class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.references :message_type, foreign_key: true
      t.string :name
      t.text :description
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :messages, :deleted_at
  end
end
