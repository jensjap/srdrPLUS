class RemoveProjectIdFromTasks < ActiveRecord::Migration[5.0]
  def change
    remove_column :tasks, :project_id_id
  end
end
