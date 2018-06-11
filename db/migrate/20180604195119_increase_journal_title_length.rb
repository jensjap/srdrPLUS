class IncreaseJournalTitleLength < ActiveRecord::Migration[5.0]
  def change
    change_column :journals, :name, :string, limit: 1000
  end
end
