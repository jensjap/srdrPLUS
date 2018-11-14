class AddRequiredInclusionReasonToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :required_inclusion_reason, :boolean, default: false
  end
end
