class CreateExportedItems < ActiveRecord::Migration[5.2]
  def change
    create_table :exported_items do |t|
      t.references  :projects_user, foreign_key: true, type: :integer
      t.references  :export_type, foreign_key: true
      t.text        :external_url, limit: 2000
      t.datetime    :deleted_at
      t.timestamps
    end
  end
end
