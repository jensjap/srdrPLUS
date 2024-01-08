class CreateMessageBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :message_boards do |t|
      t.string :key, null: false

      t.timestamps
    end

    add_index :message_boards, :key, unique: true
  end
end
