class CreateSdMetaDataQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_meta_data_queries do |t|
      t.text :query_text
      t.references :sd_meta_datum
      t.references :projects_user
      t.timestamps
    end
  end
end
