class DropTaskTypesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :task_types, if_exists:true
  end
end
