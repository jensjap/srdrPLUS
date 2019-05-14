class CreateSdSearchDatabases < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_search_databases do |t|
      t.string :name

      t.timestamps
    end
  end
end
