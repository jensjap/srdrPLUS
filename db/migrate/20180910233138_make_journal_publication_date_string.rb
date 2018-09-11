class MakeJournalPublicationDateString < ActiveRecord::Migration[5.0]
  def change
    change_column :journals, :publication_date, :string
  end
end
