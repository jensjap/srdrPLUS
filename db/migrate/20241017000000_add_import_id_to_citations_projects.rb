class AddImportIdToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_reference :citations_projects, :import, foreign_key: true, null: true
  end
end
