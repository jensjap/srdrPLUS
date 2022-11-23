class RemoveProjectsUserIdFromExportedItems < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :exported_items, name: "fk_rails_242f69471b", if_exists: true
    #remove_foreign_key :exported_items, name: "index_exported_items_on_projects_user_id", if_exists: true
    change_table :exported_items do |t|
      t.remove :projects_user_id
    end
  end
end
