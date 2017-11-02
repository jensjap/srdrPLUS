class RemovePmidFromJournals < ActiveRecord::Migration[5.0]
  def change
    remove_column :journals, :pmid, :integer
  end
end
