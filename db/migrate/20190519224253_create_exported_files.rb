class CreateExportedFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :exported_files do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.references :file_type, foreign_key: true

      t.timestamps
    end
  end
end
