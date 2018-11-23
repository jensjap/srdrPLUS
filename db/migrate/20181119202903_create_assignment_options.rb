class CreateAssignmentOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_options do |t|
      t.references :label_type, foreign_key: true
      t.references :assignment, foreign_key: true
      t.references :assignment_option_type, foreign_key: true

      t.timestamps
    end
  end
end
