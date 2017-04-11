class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.references :message_type, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
