class CreateImportedFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :imported_files do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.references :file_type, foreign_key: true
      t.references :import_type, foreign_key: true
      t.references :section, foreign_key: true

      t.timestamps
    end
  end
end
