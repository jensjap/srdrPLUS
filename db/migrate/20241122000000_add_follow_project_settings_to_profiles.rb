class AddFollowProjectSettingsToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :follow_project_settings_in_conflict_resolution, :boolean, default: true, null: false
  end
end
