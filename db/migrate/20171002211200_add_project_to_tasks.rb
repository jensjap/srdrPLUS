class AddProjectToTasks < ActiveRecord::Migration[5.0]
  def change
    add_reference :tasks, :project, foreign_key: true
  end
end
