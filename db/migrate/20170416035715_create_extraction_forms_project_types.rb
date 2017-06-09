class CreateExtractionFormsProjectTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_forms_project_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extraction_forms_project_types, :name, unique: true
    add_index :extraction_forms_project_types, :deleted_at
  end
end
