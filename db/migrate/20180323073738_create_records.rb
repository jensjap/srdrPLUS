class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.string :value
      t.references :recordable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
