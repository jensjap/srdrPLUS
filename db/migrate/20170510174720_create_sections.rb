class CreateSections < ActiveRecord::Migration[5.0]
  def change
    create_table :sections do |t|
      t.string :name
      t.boolean :default, default: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :sections, :name, unique: true
    add_index :sections, :default
    add_index :sections, :deleted_at
  end
end
