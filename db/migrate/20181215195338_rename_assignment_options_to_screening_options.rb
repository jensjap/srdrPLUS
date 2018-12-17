class RenameAssignmentOptionsToScreeningOptions < ActiveRecord::Migration[5.0]
  def change
    rename_table :assignment_options, :screening_options
  end
end
