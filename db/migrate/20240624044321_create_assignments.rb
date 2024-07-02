class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :assignor, index: true, type: :int, foreign_key: { to_table: :users }
      t.references :assignee, index: true, type: :int, foreign_key: { to_table: :users }
      t.string :assignment_type, index: true
      t.integer :assignment_id, index: true
      t.string :assignor_status
      t.string :assignee_status
      t.text :link
      t.datetime :deadline
      t.boolean :archived

      t.timestamps
    end
  end
end
