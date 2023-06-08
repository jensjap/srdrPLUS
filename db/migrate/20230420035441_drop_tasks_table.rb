class DropTasksTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :tasks, if_exists: true
  end
end
