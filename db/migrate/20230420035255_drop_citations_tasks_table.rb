class DropCitationsTasksTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :citations_tasks, if_exists: true
  end
end
