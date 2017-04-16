class AddActiveToDegreesProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :degrees_profiles, :active, :boolean
    add_index :degrees_profiles, :active
    add_index :degrees_profiles, [:degree_id, :profile_id, :active], unique: true
  end
end
