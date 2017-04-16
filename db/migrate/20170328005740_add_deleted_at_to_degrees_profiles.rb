class AddDeletedAtToDegreesProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :degrees_profiles, :deleted_at, :datetime
    add_index :degrees_profiles, :deleted_at
    add_index :degrees_profiles, [:degree_id, :profile_id], where: 'deleted_at IS NULL'
  end
end
