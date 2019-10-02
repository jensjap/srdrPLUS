class AddDeletedAtToAuthorsCitations < ActiveRecord::Migration[5.2]
  def change
    add_column :authors_citations, :id, :primary_key
    add_column :authors_citations, :deleted_at, :datetime
    add_index :authors_citations, :deleted_at
  end
end
