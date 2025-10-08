class CreateAssignmentsMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments_messages do |t|
      t.references :assignment, null: false
      t.references :message, null: false

      t.timestamps
    end

    add_index :assignments_messages, %i[assignment_id message_id], unique: true
  end
end
