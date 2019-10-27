class CreateFileTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :file_types do |t|
      t.string :name, limit: 255

      t.timestamps
    end
    add_index :file_types, :name, unique: true
  end
end
