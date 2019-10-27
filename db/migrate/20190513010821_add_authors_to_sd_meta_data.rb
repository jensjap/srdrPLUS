class AddAuthorsToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :authors, :text
  end
end
