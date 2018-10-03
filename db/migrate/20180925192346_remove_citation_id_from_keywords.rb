class RemoveCitationIdFromKeywords < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :keywords, column: :citation_id
    remove_column :keywords, :citation_id, :integer
  end
end
