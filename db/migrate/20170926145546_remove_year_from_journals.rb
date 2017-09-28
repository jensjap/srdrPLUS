class RemoveYearFromJournals < ActiveRecord::Migration[5.0]
  def change
    remove_column :journals, :year, :date
  end
end
