class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :message
      t.references :user, null: false
      t.string :room, null: false
      t.string :text, null: false
      t.boolean :pinned, null: false, default: false

      t.timestamps
    end

    add_index :messages, :room
  end
end
