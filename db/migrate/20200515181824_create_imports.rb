class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.integer :import_type_id, foreign_key: true
      t.integer :projects_user_id, foreign_key: true
    
      t.timestamps
    end

    change_table :imported_files do |t|
      t.remove :project_id
      t.remove :user_id
      t.remove :import_type_id
    end
  end
end
