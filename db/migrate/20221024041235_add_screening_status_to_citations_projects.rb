class AddScreeningStatusToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :screening_status, :string, default: :asu
  end
end
