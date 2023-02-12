class Api::V3::ExtractionsController < Api::V3::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: ExtractionPolicy)
    @extractions = ExtractionSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @extractions }
      format.fhir_json { render json: @extractions }
      format.html { render json: @extractions }
      format.json { render json: @extractions }
      format.xml { render xml: @extractions }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def show
    @extraction = ExtractionSupplyingService.new.find_by_extraction_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @extraction }
      format.fhir_json { render json: @extraction }
      format.html { render json: @extraction }
      format.json { render json: @extraction }
      format.xml { render xml: @extraction }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end

end
