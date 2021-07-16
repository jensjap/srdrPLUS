class AddUserEmailAndProjectIdToExportedItems < ActiveRecord::Migration[5.2]
  def change
    add_column :exported_items, :user_email, :string
    add_reference :exported_items, :project
  end
end
