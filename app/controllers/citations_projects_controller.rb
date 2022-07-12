class CitationsProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update_evaluation]

  def update_evaluation
    citations_project = CitationsProject.find(params[:citations_project_id])
    authorize(citations_project.project, policy_class: CitationsProjectsPolicy)
    citations_project.promote if params[:type] == CitationsProject::PROMOTE
    citations_project.demote if params[:type] == CitationsProject::DEMOTE
    render json: {
      citations_project_id: citations_project.id,
      screening_status: citations_project.screening_status
    }
  end
end
