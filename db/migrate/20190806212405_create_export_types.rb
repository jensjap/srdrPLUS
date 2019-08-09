class CreateExportTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :export_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :export_types, :name, unique: true
  end
end
