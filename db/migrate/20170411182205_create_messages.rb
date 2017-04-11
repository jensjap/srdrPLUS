class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.references :message_type, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
