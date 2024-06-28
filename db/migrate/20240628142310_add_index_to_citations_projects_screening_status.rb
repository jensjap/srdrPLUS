class AddIndexToCitationsProjectsScreeningStatus < ActiveRecord::Migration[7.0]
  def change
    add_index :citations_projects, :screening_status
  end
end
