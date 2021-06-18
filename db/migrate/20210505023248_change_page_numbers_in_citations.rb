class ChangePageNumbersInCitations < ActiveRecord::Migration[5.2]
  def change
    change_column :citations, :page_number_start, :string
    change_column :citations, :page_number_end, :string
  end
end
