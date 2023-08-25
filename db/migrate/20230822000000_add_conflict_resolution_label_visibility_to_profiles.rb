class AddConflictResolutionLabelVisibilityToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :conflict_resolution_label_visibility, :boolean, default: false
  end
end
