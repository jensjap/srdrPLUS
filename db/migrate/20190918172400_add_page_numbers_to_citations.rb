class AddPageNumbersToCitations < ActiveRecord::Migration[5.2]
  def change
    add_column :citations, :page_number_start, :integer
    add_column :citations, :page_number_end, :integer
  end
end
