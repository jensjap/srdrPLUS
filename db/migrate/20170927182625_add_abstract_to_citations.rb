class AddAbstractToCitations < ActiveRecord::Migration[5.0]
  def change
    add_column :citations, :abstract, :binary
  end
end
