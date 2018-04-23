class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.references :user, foreign_key: true
      t.references :task, foreign_key: true
      t.references :project, foreign_key: true
      t.integer :done_so_far
      t.datetime :date_assigned
      t.datetime :date_due
      t.integer :done
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :assignments, :deleted_at
  end
end
