class AddConsensusTypeRefToCitationsProjects < ActiveRecord::Migration[5.0]
  def change
    add_reference :citations_projects, :consensus_type, foreign_key: true
  end
end
