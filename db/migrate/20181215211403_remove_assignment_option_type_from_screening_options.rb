class RemoveAssignmentOptionTypeFromScreeningOptions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :screening_options, :assignment_option_type, foreign_key: true
  end
end
