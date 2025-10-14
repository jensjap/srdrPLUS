class CreateMessageExtractions < ActiveRecord::Migration[7.0]
  def change
    create_table :message_extractions do |t|
      t.bigint :message_id, null: false
      t.integer :extraction_id, null: false
      t.timestamps
    end

    add_foreign_key :message_extractions, :messages, column: :message_id
    add_foreign_key :message_extractions, :extractions, column: :extraction_id
    add_index :message_extractions, %i[message_id extraction_id], unique: true
  end
end
