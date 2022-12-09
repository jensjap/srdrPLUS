class Api::V3::KeyQuestionsController < Api::V3::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: KeyQuestionPolicy)
    @citations = KeyQuestionSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @citations }
      format.fhir_json { render json: @citations }
      format.html { render json: @citations }
      format.json { render json: @citations }
      format.xml { render xml: @citations }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def show
    @citation = KeyQuestionSupplyingService.new.find_by_key_question_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @citation }
      format.fhir_json { render json: @citation }
      format.html { render json: @citation }
      format.json { render json: @citation }
      format.xml { render xml: @citation }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end

end
