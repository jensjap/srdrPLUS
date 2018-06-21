class CreatePopulationNames < ActiveRecord::Migration[5.0]
  def change
    create_table :population_names do |t|
      t.string :name
      t.text :description, default: ''
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :population_names, :deleted_at
  end
end
