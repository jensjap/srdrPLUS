class CreateTimepointNames < ActiveRecord::Migration[5.0]
  def change
    create_table :timepoint_names do |t|
      t.string :name
      t.string :unit
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :timepoint_names, :deleted_at
  end
end
