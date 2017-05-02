class CreateDegrees < ActiveRecord::Migration[5.0]
  def change
    create_table :degrees do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :degrees, :name, unique: true
    add_index :degrees, :deleted_at
  end
end
