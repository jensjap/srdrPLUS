class AddProsperoLinkToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :prospero_link, :string
  end
end
