class Api::V3::ProjectsController < Api::V3::BaseController
  before_action :set_project, only: [:show, :process_and_email]

  def show
    authorize(@project)
    @project_bundle = AllResourceSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @project_bundle }
      format.fhir_json { render json: @project_bundle }
      format.html { render json: @project_bundle }
      format.json { render json: @project_bundle }
      format.xml { render xml: @project_bundle }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def process_and_email
    authorize(@project)
    ProcessAndEmailFhirJob.perform_later(@project.id, current_user.email)
    render 'process_and_email'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end
end
