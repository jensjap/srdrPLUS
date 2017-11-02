class AddPilotFlagToCitationsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :citations_projects, :pilot_flag, :boolean
  end
end
