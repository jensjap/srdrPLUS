class RemoveCitationIdFromAuthors < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :authors, column: :citation_id
    remove_column :authors, :citation_id, :integer
  end
end
