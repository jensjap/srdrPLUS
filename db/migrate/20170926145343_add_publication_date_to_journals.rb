class AddPublicationDateToJournals < ActiveRecord::Migration[5.0]
  def change
    add_column :journals, :publication_date, :date
  end
end
