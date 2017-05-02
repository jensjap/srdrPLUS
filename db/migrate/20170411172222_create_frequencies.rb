class CreateFrequencies < ActiveRecord::Migration[5.0]
  def change
    create_table :frequencies do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :frequencies, :deleted_at
  end
end
