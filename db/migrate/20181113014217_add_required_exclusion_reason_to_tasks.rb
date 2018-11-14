class AddRequiredExclusionReasonToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :required_exclusion_reason, :boolean, default: false
  end
end
