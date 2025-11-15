class ChangeProfilesStorageToMediumtext < ActiveRecord::Migration[7.0]
  def up
    change_column :profiles, :storage, :mediumtext
  end

  def down
    change_column :profiles, :storage, :text
  end
end
