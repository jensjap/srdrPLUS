class CreateMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :measures do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :measures, :deleted_at
  end
end
