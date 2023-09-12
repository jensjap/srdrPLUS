class AddStorageToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :storage, :text
  end
end
