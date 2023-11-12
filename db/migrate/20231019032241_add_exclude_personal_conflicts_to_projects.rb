class AddExcludePersonalConflictsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :exclude_personal_conflicts, :boolean, default: false, null: false
  end
end
