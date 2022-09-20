class CreateSfOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_options do |t|
      t.references :sf_cell
      t.string :name, null: false
      t.boolean :with_followup, default: false, null: false
      t.timestamps
    end
    add_index :sf_options, %i[name sf_cell_id], unique: true
  end
end
