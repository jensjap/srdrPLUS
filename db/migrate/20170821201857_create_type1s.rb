class CreateType1s < ActiveRecord::Migration[5.0]
  def change
    create_table :type1s do |t|
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :type1s, [:name, :description], length: { description: 255 }, unique: true
    add_index :type1s, :deleted_at
  end
end
