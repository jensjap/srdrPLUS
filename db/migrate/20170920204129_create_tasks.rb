class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.references :task_type, foreign_key: true
      t.references :project, foreign_key: true
      t.integer :num_assigned
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :tasks, :deleted_at
  end
end
