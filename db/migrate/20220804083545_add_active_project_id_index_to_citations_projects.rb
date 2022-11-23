class AddActiveProjectIdIndexToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_index :citations_projects, %i[project_id active],
              comment: 'speeds up the my projects page when projects have a lot of citations_projects'
  end
end
