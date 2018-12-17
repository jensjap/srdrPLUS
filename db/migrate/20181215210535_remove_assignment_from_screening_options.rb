class RemoveAssignmentFromScreeningOptions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :screening_options, :assignment, foreign_key: true
  end
end
