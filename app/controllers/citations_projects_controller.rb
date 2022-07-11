class CitationsProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update_evaluation]

  def update_evaluation
    citations_project = CitationsProject.find(params[:citations_project_id])
    if params[:type] == CitationsProject::PROMOTE
      citations_project.promote
    elsif params[:type] == CitationsProject::DEMOTE
      citations_project.demote
    end
    render json: {
      citations_project_id: citations_project.id,
      screening_status: citations_project.screening_status
    }
  end
end
