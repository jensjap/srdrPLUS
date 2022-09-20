class CreateSfCells < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_cells do |t|
      t.references :sf_row
      t.references :sf_column
      t.string :cell_type, null: false
      t.integer :min, null: false, default: 0
      t.integer :max, null: false, default: 255
      t.boolean :with_equality, null: false, default: false
      t.timestamps
    end
    add_index :sf_cells, %i[sf_row_id sf_column_id], unique: true
  end
end
