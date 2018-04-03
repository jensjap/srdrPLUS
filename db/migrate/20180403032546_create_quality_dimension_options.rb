class CreateQualityDimensionOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :quality_dimension_options do |t|
      t.text :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :quality_dimension_options, :deleted_at
  end
end
