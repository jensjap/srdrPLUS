class AddAddtlIdFieldsToCitations < ActiveRecord::Migration[5.2]
  def change
    add_column :citations, :registry_number, :string
    add_column :citations, :doi, :string
    add_column :citations, :other, :string
  end
end
