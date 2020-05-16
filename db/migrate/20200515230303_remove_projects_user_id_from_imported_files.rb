class RemoveProjectsUserIdFromImportedFiles < ActiveRecord::Migration[5.2]
  def change
    change_table :imported_files do |t|
      t.remove :projects_user_id
    end
  end
end
