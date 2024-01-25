class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :rooms, %i[name]
  end
end
