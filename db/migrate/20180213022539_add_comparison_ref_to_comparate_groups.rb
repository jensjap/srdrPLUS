class AddComparisonRefToComparateGroups < ActiveRecord::Migration[5.0]
  def change
    add_reference :comparate_groups, :comparison, foreign_key: true
  end
end
