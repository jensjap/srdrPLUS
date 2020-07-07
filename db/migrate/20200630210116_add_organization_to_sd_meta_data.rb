class AddOrganizationToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :organization, :text
  end
end
