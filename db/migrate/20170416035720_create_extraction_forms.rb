class CreateExtractionForms < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms do |t|
      t.references :extraction_form_type, foreign_key: true
      t.string :name
      t.boolean :private
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extraction_forms, :deleted_at
  end
end
