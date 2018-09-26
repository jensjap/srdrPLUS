class CreateJoinTableCitationsAuthors < ActiveRecord::Migration[5.0]
  def change
    create_join_table :citations, :authors do |t|
      t.index [:citation_id, :author_id]
      # t.index [:author_id, :citation_id]
    end
  end
end
