class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :sent
      t.string :action
      t.string :resource
      t.integer :resource_id
      t.string :notes
      t.timestamps
    end
  end
end
