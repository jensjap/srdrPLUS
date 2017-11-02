class RemoveRefmanFromJournals < ActiveRecord::Migration[5.0]
  def change
    remove_column :journals, :refman, :integer
  end
end
