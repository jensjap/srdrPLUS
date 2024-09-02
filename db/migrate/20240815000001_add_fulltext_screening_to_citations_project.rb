class AddFulltextScreeningToCitationsProject < ActiveRecord::Migration[7.0]
  def change
    add_reference :citations_projects, :fulltext_screening, foreign_key: true
  end
end
