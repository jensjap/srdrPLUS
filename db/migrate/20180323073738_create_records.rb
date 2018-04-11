class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.string :name
      t.references :recordable, polymorphic: true, index: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :records, :deleted_at
  end
end
