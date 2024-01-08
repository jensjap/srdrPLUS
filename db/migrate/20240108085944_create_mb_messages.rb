class CreateMbMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :mb_messages do |t|
      t.references :message_board, null: false
      t.references :mb_message
      t.string :text, null: false
      t.boolean :pinned, null: false, default: false

      t.timestamps
    end
  end
end
