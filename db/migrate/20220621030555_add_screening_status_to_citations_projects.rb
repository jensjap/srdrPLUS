class AddScreeningStatusToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :screening_status, :string, null: false, default: 'CP'
    add_index :citations_projects, :screening_status
  end
end
