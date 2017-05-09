class CreateExtractionFormTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_form_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extraction_form_types, :deleted_at
  end
end
