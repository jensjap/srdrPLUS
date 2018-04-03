class CreateQualityDimensionSections < ActiveRecord::Migration[5.0]
  def change
    create_table :quality_dimension_sections do |t|
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :quality_dimension_sections, :deleted_at
  end
end
