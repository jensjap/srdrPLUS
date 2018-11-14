class AddRequiredMaybeReasonToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :required_maybe_reason, :boolean, default: false
  end
end
