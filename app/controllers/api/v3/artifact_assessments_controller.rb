class Api::V3::ArtifactAssessmentsController < Api::V3::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: ArtifactAssessmentPolicy)
    @artifact_assessments = AsLabelSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @artifact_assessments }
      format.fhir_json { render json: @artifact_assessments }
      format.html { render json: @artifact_assessments }
      format.json { render json: @artifact_assessments }
      format.xml { render xml: @artifact_assessments }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Project not found' }, status: :not_found
  end
end
