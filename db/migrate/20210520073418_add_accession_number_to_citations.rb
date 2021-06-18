class AddAccessionNumberToCitations < ActiveRecord::Migration[5.2]
  def change
    add_column :citations, :accession_number, :string
  end
end
