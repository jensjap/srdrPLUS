class CreateImportTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :import_types do |t|
      t.string :name, limit: 255

      t.timestamps
    end
    add_index :import_types, :name, unique: true
  end
end
