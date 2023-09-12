class Api::V4::ExtractionsController < Api::V4::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: ExtractionPolicy)
    @extractions = EppiService.new.export_by_project_id(@project.id)
    respond_to do |format|
      format.html { render json: @extractions }
      format.json { render json: @extractions }
      format.xml { render xml: @extractions }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
