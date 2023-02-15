class DropTasks < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :tasks, name: 'fk_rails_02e851e3b7'
    remove_index :tasks, :project_id
  end
end
