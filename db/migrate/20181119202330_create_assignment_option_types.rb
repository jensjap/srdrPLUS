class CreateAssignmentOptionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_option_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
