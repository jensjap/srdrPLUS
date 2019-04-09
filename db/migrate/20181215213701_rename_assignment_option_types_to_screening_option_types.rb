class RenameAssignmentOptionTypesToScreeningOptionTypes < ActiveRecord::Migration[5.0]
  def change
    rename_table :assignment_option_types, :screening_option_types
  end
end
