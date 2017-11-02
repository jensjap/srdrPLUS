class AddPmidToCitations < ActiveRecord::Migration[5.0]
  def change
    add_column :citations, :pmid, :integer
  end
end
