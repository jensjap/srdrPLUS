class AddImportIdToImportedFiles < ActiveRecord::Migration[5.2]
  def change
    change_table :imported_files do |t|
      t.integer :import_id
    end
  end
end
