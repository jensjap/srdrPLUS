class AddProjectsUserReferenceToImportedFiles < ActiveRecord::Migration[5.0]
  def change
    add_reference :imported_files, :projects_user, index: true, foreign_key: true    
  end
end
