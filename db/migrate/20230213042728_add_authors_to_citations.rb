class AddAuthorsToCitations < ActiveRecord::Migration[7.0]
  def change
    add_column :citations, :authors, :text
    add_index :citations, :authors, length: 255
  end
end
