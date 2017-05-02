class CreateExtractionForms < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extraction_forms, :deleted_at
  end
end
