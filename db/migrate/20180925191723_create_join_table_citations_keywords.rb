class CreateJoinTableCitationsKeywords < ActiveRecord::Migration[5.0]
  def change
    create_join_table :citations, :keywords do |t|
      t.index [:citation_id, :keyword_id]
      # t.index [:keyword_id, :citation_id]
    end
  end
end
